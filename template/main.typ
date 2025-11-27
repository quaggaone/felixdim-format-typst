#import "@local/felixdim-format:0.1.0": fd-doc

#show: fd-doc.with(
  title: [Document Title],
  author: "Your Name",
  description: [A brief description of your document],
  date: datetime.today(),
  lang: "en",
  region: "eu",
)

= Introduction

Start writing your document here. This template uses the felixdim-format package with custom styling for documents.

== Features

- Clean typography using IBM Plex fonts
- Code syntax highlighting with codly
- Custom heading styles
- Automatic page numbering and footers

== Example Code

Here's an example of inline code: `let x = 42`

```python
def hello_world():
    print("Hello, World!")
```

= Conclusion

Replace this template content with your own text.
