package main

import (
	"encoding/base64"
	"flag"
	"fmt"
	"io"
	"os"
	"path"
	"regexp"
	"text/template"
)

func main() {
	flag.Parse()
	env := make(map[string]string)
	eqPattern := regexp.MustCompile("\\=")
	envList := os.Environ()

	for i := range envList {
		pieces := eqPattern.Split(envList[i], 2)
		if len(pieces) == 2 {
			env[pieces[0]] = pieces[1]
			env[pieces[0]+"_BASE64"] = base64.StdEncoding.EncodeToString([]byte(pieces[1]))
		} else {
			fmt.Fprintf(os.Stderr, "Invalid environ found: %s\n", envList[i])
			os.Exit(2)
		}
	}

	for i := 0; i < flag.NArg(); i++ {
		inpath := flag.Arg(i)

		if err := templateYamlFile(env, inpath, os.Stdout); err != nil {
			panic(err)
		}
	}
}

func templateYamlFile(params map[string]string, inpath string, out io.Writer) error {
	if tmpl, err := template.New(path.Base(inpath)).ParseFiles(inpath); err != nil {

		return err

	} else {
		if err := tmpl.Execute(out, params); err != nil {
			return err
		}
	}
	_, err := out.Write([]byte("\n---\n"))
	return err
}
