// PROJECT PLANNER · Quarto + Typst
// All style/layout changes live here; edit blank.qmd or filled.qmd for content.
// Version 2: larger type, flush-left title, vertically centered table cells,
// real bullet lists, and no empty bullets or ruled Notes lines.

// ── THEME: change these values to restyle every report ────────────────
#let font-family = ("Libertinus Sans", "Liberation Sans", "Arial")
#let body-size = 11pt            // formerly 8.6pt
#let heading-size = 11.5pt
#let title-size = 20pt
#let ink = rgb("#263442")
#let navy = rgb("#254764")
#let muted = rgb("#627483")
#let line-color = rgb("#B3C1CA")
#let light-fill = rgb("#F0F4F6")
#let active-fill = rgb("#C4D9E6")

// Table rows control height. The cell alignments include `horizon`,
// so text is centered *vertically*, never nudged upward by an inner box.
#let table-title(title, cols) = table.cell(
  colspan: cols,
  fill: light-fill,
  align: center + horizon,
  inset: (x: 4pt, y: 1pt),
)[#text(weight: "bold", fill: navy, size: heading-size)[#title]]

#let td(body, where: left, fill: none) = table.cell(
  align: where + horizon,
  fill: fill,
  inset: (x: 5pt, y: 1pt),
)[#body]

#let tick(checked) = if checked {
  text(weight: "bold", fill: navy)[✓]
} else { [] }

#let milestones-table(data) = {
  let n = calc.max(5, data.len())
  let cells = (
    table-title("Project Milestones", 7),
    td([Milestone], where: center),
    table.cell(colspan: 4, align: center + horizon, inset: 1pt)[Progress],
    td([Due], where: center),
    td([✓], where: center),
  )
  for i in range(n) {
    let entry = if i < data.len() { data.at(i) } else {
      (name: [], progress: 0, due: [], done: false)
    }
    cells.push(td(entry.name))
    for j in range(4) {
      cells.push(td([], where: center,
        fill: if entry.progress >= (j + 1) * 25 { active-fill } else { none }))
    }
    cells.push(td(entry.due, where: center))
    cells.push(td(tick(entry.done), where: center))
  }
  table(
    columns: (3.55fr, 0.40fr, 0.40fr, 0.40fr, 0.40fr, 1.34fr, 0.42fr),
    rows: (25pt, 24pt) + (23pt,) * n,
    stroke: 0.65pt + line-color,
    inset: 0pt,
    ..cells,
  )
}

#let timeline-table(data) = {
  let n = calc.max(5, data.len())
  let cells = (
    table-title("Project Timeline", 13),
    table.cell(rowspan: 2, align: center + horizon, inset: 1pt)[Segment],
    table.cell(colspan: 12, align: center + horizon, inset: 1pt)[Week],
  )
  for week in range(1, 13) {
    cells.push(td(text(size: 8.7pt, str(week)), where: center))
  }
  for i in range(n) {
    let entry = if i < data.len() { data.at(i) } else {
      (segment: [], start: 0, end: 0)
    }
    cells.push(td(entry.segment))
    for week in range(1, 13) {
      cells.push(td([], where: center,
        fill: if entry.start > 0 and entry.start <= week and entry.end >= week {
          active-fill
        } else { none }))
    }
  }
  table(
    columns: (3.25fr,) + (0.42fr,) * 12,
    rows: (25pt, 23pt, 21pt) + (23pt,) * n,
    stroke: 0.65pt + line-color,
    inset: 0pt,
    ..cells,
  )
}

#let tasks-table(data) = {
  let n = calc.max(7, data.len())
  let cells = (
    table-title("Project Tasks", 5),
    td([Task], where: center),
    td([Owner], where: center),
    td([Start], where: center),
    td([End], where: center),
    td([✓], where: center),
  )
  for i in range(n) {
    let entry = if i < data.len() { data.at(i) } else {
      (task: [], owner: [], start: [], end: [], done: false)
    }
    cells.push(td(entry.task))
    cells.push(td(entry.owner, where: center))
    cells.push(td(entry.start, where: center))
    cells.push(td(entry.end, where: center))
    cells.push(td(tick(entry.done), where: center))
  }
  table(
    columns: (3.05fr, 1.10fr, 1.20fr, 1.20fr, 0.42fr),
    rows: (25pt, 24pt) + (23pt,) * n,
    stroke: 0.65pt + line-color,
    inset: 0pt,
    ..cells,
  )
}

// Only data provided in the YAML is listed. Empty lists are truly empty.
// `list` is Typst's own bullet-list function, not a manually drawn glyph.
#let list-panel(title, values) = block(
  width: 100%, height: 1.54in,
  stroke: 0.7pt + line-color,
  inset: (x: 10pt, y: 8pt),
)[
  #text(weight: "bold", fill: navy, size: heading-size)[#title]
  #if values.len() > 0 [
    #v(6pt)
    #list(tight: true, indent: 11pt, body-indent: 6pt,
      spacing: 3.2pt, ..values)
  ]
]

// Notes: open blank space for handwritten notes when YAML `notes: []`;
// populated notes appear as bullet points without horizontal ruling.
#let notes-panel(values) = block(
  width: 100%, height: 5.54in,
  stroke: 0.7pt + line-color,
  inset: (x: 12pt, y: 9pt),
)[
  #align(center)[#text(weight: "bold", fill: navy, size: heading-size)[Notes]]
  #if values.len() > 0 [
    #v(11pt)
    #list(tight: true, indent: 16pt, body-indent: 7pt,
      spacing: 8pt, ..values)
  ]
]

// Called by typst-show.typ with the YAML fields in blank.qmd / filled.qmd.
#let article(
  project-name: [], team-lead: [], objective: [], due-date: [],
  milestones: (), timeline: (), tasks: (),
  in-scope: (), out-of-scope: (), success-criteria: (), deliverables: (),
  notes: (), appendix: false,
  doc,
) = {
  set text(font: font-family, size: body-size, fill: ink)
  set par(leading: 0.44em, spacing: 0pt)

  // PAGE 1
  grid(
    columns: (1fr, 1.05fr),
    gutter: 16pt,
    // LEFT ALIGNED with the other content/tables, inside the page margin.
    align(left + horizon)[#text(size: title-size, weight: "bold", fill: navy)[Project Planner]],
    block(width: 100%, fill: light-fill, stroke: 0.7pt + line-color,
      inset: (x: 8pt, y: 6pt))[
      #text(weight: "bold")[Project:] #project-name
      #linebreak()
      #text(weight: "bold")[Team Lead:] #team-lead
    ],
  )
  v(10pt)
  block(width: 100%, stroke: 0.7pt + line-color, inset: (x: 9pt, y: 7pt))[
    #grid(columns: (4fr, 1.43fr), gutter: 12pt,
      [#text(weight: "bold")[Objective:] #objective],
      [#text(weight: "bold")[Due date:] #due-date],
    )
  ]
  v(11pt)
  milestones-table(milestones)
  v(11pt)
  timeline-table(timeline)
  v(11pt)
  tasks-table(tasks)

  // PAGE 2
  pagebreak()
  grid(columns: (1fr, 1fr), gutter: 11pt,
    list-panel("In scope", in-scope),
    list-panel("Out of scope", out-of-scope),
  )
  v(11pt)
  grid(columns: (1fr, 1fr), gutter: 11pt,
    list-panel("Success criteria", success-criteria),
    list-panel("Deliverables", deliverables),
  )
  v(13pt)
  notes-panel(notes)

  if appendix {
    pagebreak()
    set text(size: body-size)
    heading(level: 1)[Project Details / Appendix]
    doc
  }
}
