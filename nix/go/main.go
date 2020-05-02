package main

import (
	"io/ioutil"
	"log"

	bf "github.com/russross/blackfriday/v2"
)

func main() {
	b, _ := ioutil.ReadFile("../content/blog/applicative-compose/index.md")

	md := bf.Run(b)

	log.Print(string(md))
}
