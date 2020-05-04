package main

import (
	"flag"
	"io"
	"io/ioutil"
	"log"
	"regexp"
	"strings"

	"bufio"
	"html/template"
	"os"
	"path/filepath"

	bf "github.com/russross/blackfriday/v2"
	"gopkg.in/yaml.v2"
)

type Frontmatter struct {
	Title   string `yaml:"title"`
	Date    string `yaml:"date"`
	Publish bool   `yaml:"publish"`
}

type ParsedPost struct {
	FrontMatter Frontmatter
	Body        string
}

type TOC = map[string]ParsedPost

func parsePost(post io.Reader) (ParsedPost, error) {
	var body strings.Builder
	var frontMatter strings.Builder

	scanner := bufio.NewScanner(post)
	start := false

	for scanner.Scan() {
		if scanner.Text() == "---" {
			start = !start
			continue
		}

		if start {
			frontMatter.WriteString(scanner.Text() + "\n")
		} else {
			body.WriteString(scanner.Text() + "\n")
		}
	}

	fm := Frontmatter{}

	err := yaml.Unmarshal([]byte(frontMatter.String()), &fm)
	if err != nil {
		log.Fatal(err)
	}

	parsedPost := ParsedPost{fm, body.String()}

	return parsedPost, nil
}

func findPosts(root string) ([]string, error) {
	var posts []string

	mdRegEx, err := regexp.Compile(`.*\.md$`)
	if err != nil {
		log.Fatal(err)
	}

	err = filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if mdRegEx.MatchString(info.Name()) {
			posts = append(posts, path)
		}

		return nil
	})
	if err != nil {
		log.Fatal(err)
	}

	return posts, nil
}

func titleToFileName(s string) string {
	var out []string

	for _, word := range strings.Split(s, " ") {
		out = append(out, strings.ToLower(word))
	}

	return strings.Join(out, "_")
}

func renderPostToFile(post ParsedPost, outDir string, postTemplate *template.Template) (string, error) {
	md := bf.Run([]byte(post.Body), bf.WithExtensions(bf.FencedCode|bf.Footnotes))

	var rendered strings.Builder

	err := postTemplate.Execute(&rendered, struct {
		Title string
		Body  template.HTML
	}{
		Title: post.FrontMatter.Title,
		Body:  template.HTML(md),
	})
	if err != nil {
		log.Fatal(err)
	}

	targetPath := outDir + "/" + titleToFileName(post.FrontMatter.Title) + ".html"

	err = ioutil.WriteFile(targetPath, []byte(rendered.String()), 0644)
	if err != nil {
		log.Fatal(err)
	}

	return targetPath, nil
}

func main() {
	contentFlag := flag.String("contentdir", "", "Path to directory with markdown content")
	outDir := flag.String("outdir", "", "Path to directory where HTML should be saved")
	templateDir := flag.String("templatedir", "", "Path to directory where templates are stored")

	flag.Parse()

	postTemplate, err := template.ParseFiles(*templateDir+"/"+"index.html.tmpl", *templateDir+"/"+"post.html.tmpl")
	if err != nil {
		log.Fatal(err.Error())
	}

	tocTemplate, err := template.ParseFiles(*templateDir+"/"+"index.html.tmpl", *templateDir+"/"+"toc.html.tmpl")
	if err != nil {
		log.Fatal(err.Error())
	}

	posts, err := findPosts(*contentFlag)
	if err != nil {
		log.Fatal(err)
	}

	toc := make(TOC)

	for _, post := range posts {
		file, err := os.Open(post)
		if err != nil {
			log.Fatal(err)
		}
		defer file.Close()

		parsedPost, err := parsePost(file)
		if err != nil {
			log.Fatal(err)
		}

		target, err := renderPostToFile(parsedPost, *outDir, postTemplate)
		if err != nil {
			log.Fatal(err)
		}

		relTarget, err := filepath.Rel(*outDir, target)
		if err != nil {
			log.Fatal(err)
		}

		toc[relTarget] = parsedPost
	}

	indexFile, err := os.Create(*outDir + "/" + "index.html")
	if err != nil {
		log.Fatal(err)
	}

	err = tocTemplate.Execute(indexFile, struct {
		Title string
		TOC   TOC
	}{
		Title: "foo",
		TOC:   toc,
	})
	if err != nil {
		log.Fatal(err)
	}
}
