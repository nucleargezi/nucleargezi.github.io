
#let main(
  title: "Untitled",
  desc: [This is a blog post.],
  date: "2024-08-15",
  content,
) = [
  #metadata((
    title: title,
    author: "Myriad-Dreamin",
    desc: desc,
    date: date,
  )) <frontmatter>

  #content
]
