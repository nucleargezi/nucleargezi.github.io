#import "/typ/templates/blog.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#show: main-en.with(
  title: "Comment System",
  desc: [I built a simple comment system for my blog.],
  date: "2025-06-17T11:11:54+08:00",
  tags: (
    blog-tags.programming,
    blog-tags.software-engineering,
    blog-tags.golang,
    blog-tags.typst,
  ),
)

#let argument-point = counter("comment-sys-pts")
#let argument-points(body) = if sys-is-html-target {
  show enum.item: it => {
    argument-point.step()
    context html.elem("li", attrs: (id: "P" + str(argument-point.get().at(0))), it.body)
  }
  html.elem("ol", body)
} else {
  set enum(
    numbering: it => {
      argument-point.step()
      numbering("1.", it)
      context box(width: 0pt, height: 0pt)[#math.equation(numbering: "1.")[]#label(
          "arg:" + str(argument-point.get().at(0)),
        )]
    },
  )
  body
}

#let local-rules(body) = {
  show ref: it => if not str(it.target).starts-with("arg:") {
    it
  } else {
    if sys-is-html-target {
      let (_, id) = str(it.target).split(":")
      html.elem("a", attrs: (href: "#P" + id), "Point #" + id)
    } else {
      link(it.target, "Point #" + str(it.target).split(":").at(1))
    }
  }

  body
}

#let edge-box(body) = box(fill: rgb("#10aec2"), inset: 4pt, text(white, body))

#show: local-rules

I would like to pick a suitable comment system for my blog. My considerations are:
#argument-points[
  + It should have minimal backend requirements. If there is a backend, it should be reachable in global-wide.
  + It should be able to hide personal information like email address. I know that many email addresses are not a secret, but I don't want to give a change to reveal it from my blog.
  + It should be easy to use so that people will not stop commenting because of the complexity.
  + It should use JavaScript in frontend as little as possible.
]

This comment system supports:
- Markdown syntax and mathematical formulas.
- User mentions and comment replies.
- Email notifications.

= Email the Old Fashion

I first investigate the mailto protocol. That is an actual old falsionm but I suspect its availablility. People rarely click `mailto:` (imo) and the remaining usage is leaking the email address. It is a simple and doesn't require any JavaScript and backend. But it has some problems:
- When the user clicks the link, it will open the user's email client, while people usually doesn't configure their email client, so they will go to the Outlook or Thunderbird and might exit it quickly. In worst case, they will not comment to my blog anymore. This breaks @arg:3.
- The mailto link will reveal my email address. It is not a big problem, but it breaks @arg:2.

= Abusing GitHub

No backend is a lie. It just appears in another way. Another most popular comment system is utilizing GitHub issues. It is a good idea, but it also has some problems:
- It requires the user to have a GitHub account, which is not always the case. This breaks @arg:3.
- The GitHub is not available in some countries. This breaks @arg:1.
- No, I didn't consider @arg:4, which is only a bonus, but such comment system usually requires JavaScript to render and process the comments.

= My Home-made Comment System

Since we have served the static files in Golang's HTTP server, what about deploying a simple comment system on the same server? People who can access the frontend resources should be able to access the same server. This should have some downsides, but can be a easy start.

Should I use any backend framework? I bet this is not necessary at least we are not aiming to make a blog sites that handlers 100k of comment requests per second.

In go, this is easy to start:

#let comment-backend = ```go
package main

import (
	...

	"database/sql"
	_ "github.com/mattn/go-sqlite3"
)

type Handler struct {
	db *sql.DB
}

func (h *Handler) makeTables() {
	h.db.Exec("CREATE TABLE IF NOT EXISTS comments (id INTEGER PRIMARY KEY AUTOINCREMENT, article_id TEXT, email TEXT, content TEXT, authorized BOOLEAN NOT NULL DEFAULT FALSE, created_at INTEGER)")
}

func (h *Handler) handleCommentPost(w http.ResponseWriter, r *http.Request) {
  articleId, content, email, createdAt := r.FormValue("article_id"), r.FormValue("content"), r.FormValue("email"), time.Now().UnixMilli()
  _, err := mail.ParseAddress(email)

	// Validate the input
	if err != nil || len(content) > 4096 || len(email) > 128 || !h.mustExistsArticle(articleId, w) {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Inserts comment into database
	_, err = h.db.Exec("INSERT INTO comments (article_id, content, email, authorized, created_at) VALUES (?, ?, ?, ?, ?)", articleId, content, email, false, createdAt)
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Respond with success
}
```
#comment-backend

Now, we can get comments periodically from the backend and render them in the static-site blog.

= Comentario

I also surveyed some self-hosted comment systems, like #link("https://comentario.app")[Comentario.] What I don't understand is what it is saying in #link("https://docs.comentario.app/en/installation/requirements/#sqlite")[Requirements: Sqlite:]

#quote(block: true)[
  - It’s not scalable: it will probably be okay for up to a few thousand comments, but beyond that the performance will degrade.

  That said, it’s probably fine to use SQLite as a minimal option to try out Comentario, or even to use it for your (low traffic) personal blog.
]

I'm not offensive and respect that comentario has beautiful and out look and is totally free. Either my experience is not enough that I didn't ever handle a blog with thousands of comments, or comentario is too heavy to use Sqlite as a backend.

= Continuing developing my Comment System

This doesn't mean that I will use my home-made comment system eventually. I continued to develop it a bit to be able to reply to my friends.

#figure(
  code-image.with(class: "center")(theme => [
    // #set page(width: auto, height: auto, margin: 5mm, fill: white)
    #let node-text = text.with(white, font: "New Computer Modern")
    #let colors = (green.darken(20%), eastern, blue.lighten(20%))
    #let edge = edge.with(stroke: theme.main-color)

    #diagram(
      edge-stroke: 1pt,
      node-corner-radius: 5pt,
      edge-corner-radius: 8pt,
      mark-scale: 80%,

      node((0, 0), node-text[Anybody\ Sending Comment], fill: colors.at(0)),
      node((0, 2), node-text[Email Owner\ Cancel Confirmation], fill: colors.at(0)),

      node((1, 0), node-text[Backend Receiving/\ Filtering Comments], fill: colors.at(1)),
      node((1, 1), node-text[Site Owner Sending\ Authorizing Email], fill: colors.at(1)),
      node((1, 2), node-text[Site Owner \ Deleting Comment], fill: colors.at(1)),

      node((3, 0), node-text[Frontend built with\ Unauthorized Comments], fill: colors.at(2)),
      node((3, 1), node-text[Frontend built with\ Authorized Comments], fill: colors.at(2)),
      node((3, 2), node-text[Frontend built with\ Removing Comments], fill: colors.at(2)),
      // node((2, 0), align(center)[arithmetic & logic \ unit (ALU)], fill: colors.at(1)),
      // node((2, -1), [control unit (CU)], fill: colors.at(1)),
      // node((4, 0), [output], fill: colors.at(2), shape: fletcher.shapes.hexagon),

      edge((0, 0), "r", "-}>"),
      edge((0, 2), "r", "-}>"),
      edge(
        (0, 0),
        "dd",
        "--}>",
      ),

      edge((1, 0), "d", "-}>"),
      edge((1, 1), "d", "-}>"),

      edge(
        (1, 1),
        (0, 2),
        "-}>",
        label: edge-box[Racing Authorization],
        label-anchor: "center",
        label-angle: -10deg,
      ),

      edge((3, 0), "d", "-}>"),
      edge((3, 1), "d", "-}>"),

      edge((1, 0), "rr", "-}>"),
      edge((1, 1), "rr", "-}>", label: [Wait a Bit]),
      edge((1, 2), "rr", "-}>"),
    )
  ]),
  caption: "A simple comment system with minimal backend requirements.",
)

== Sending and Rendering Comment without Authorization

This minimalize the steps to send a comment. Registering or oauth is not required.

The backend only sends an email to the owner, so it can be easily deployed on cloud and distributed computing services like cloudflare workers.

- No, I still use the golang backend in the previous step because it works, but it can be easily ported the cloudflare workers. I may use the cloudflare workers in the future when I find it doesn't work perfectly in future.

== Authorization Steps

The email can be confirmed by the owner of the email address in a racing manner:
+ I will send an email to notify the email owner.
+ The email owner doesn't have to send back a confirmation email. I will wait a bit to remove the `[Unauthorized]` tag from the comment.
  - It will be a day if the email owner doesn't continue comment on the blog site.
  - Otherwise, when we observe the activity of the email owner, we can remove the tag immediately.

= Custom Markup made with Typst

The comment is in markdown format with extended syntax. It is rendered by Typst's `cmark` package, so it can be easily customized. Two custom syntax are extended.

== `[user:name]`

People can mention by the name other people that "have been occurred in the current blog site". It is rendered as a hash link so no JavaScript is required to handle it.

- I don't know if there will be two "Steven" commenting on my blog, but I can think of it when it really happens.

== `[comment:id]`

People can reply to a comment in the same article by its id. And it is rendered as a hash link along with the first line of content of the comment.

People who have been mentioned in the comment will receive an email notification.

#figure(
  code-image.with(class: "center")(theme => [
    // #set page(width: auto, height: auto, margin: 5mm, fill: white)
    #let node-text = text.with(white, font: "New Computer Modern")
    #let colors = (green.darken(20%), eastern, blue.lighten(20%))
    #let edge = edge.with(stroke: theme.main-color)

    #diagram(
      edge-stroke: 1pt,
      node-corner-radius: 5pt,
      edge-corner-radius: 8pt,
      mark-scale: 80%,

      node((0, 0), node-text[Anybody\ Sending Comment], fill: colors.at(0)),
      node((0, 2), node-text[People Receiving\ Notification about Mentions], fill: colors.at(0)),

      node((1, 1), node-text[Site Owner Sending\ Notification Email], fill: colors.at(1)),

      edge((0, 0), (1, 1), "-}>"),
      edge(
        (0, 0),
        "dd",
        "--}>",
      ),

      edge(
        (1, 1),
        (0, 2),
        "-}>",
        label: edge-box[BCC the Email],
        label-anchor: "center",
        label-angle: -10deg,
      ),
    )
  ]),
  caption: "The notification of mentioned people.",
)

The "BCC the Email" means that people won't see the email address of other people who have been mentioned in the comment, so it won't violate @arg:2.

= Post Story: gravatar

Should I use gravatar to show the avatar of the commenter? It is a good idea, but I didn't do it because it doesn't really protect the email address of the commenter.

We know that gravatar hashes the email address to avoid the exhibition the plain text email address occurring on the gravatar URL. However,
- Anybody can collect a list of email addresses and their gravatar hashes to find the real email address.
- Even if somebody doesn't try to reveal the email address, they can collect all the occurrences of the gravatar URLs to infer the activities of the commenter.

It is not that important to really protect the email address, but it is better to achieve that because we don't know whether anybody cares about that.
