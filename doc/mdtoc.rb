#!/usr/bin/env ruby

# A little Markdown filter that scans your document for headings,
# numbers them, adds anchors, and inserts a table of contents.
#
# To use it, make sure the headings you want numbered and linked are
# in this format:
#
#     ### Title ###
#
# I.e. they must have an equal number of octothorpes around the title
# text. (In Markdown, `#` means `h1`, `##` means `h2`, and so on.)
# The table of contents will be inserted before the first such
# heading.
#
# Released into the public domain.
# Sam Stephenson <sstephenson@gmail.com>
# 2011-04-30

def mdtoc(markdown)
  titles = []
  lines = markdown.split($/)
  start = nil

  # First pass: Scan the Markdown source looking for titles of the
  # format: `### Title ###`. Record the line number, header level
  # (number of octothorpes), and text of each matching title.
  lines.each_with_index do |line, line_no|
    if line.match(/^(\#{1,6})\s+(.+?)\s+\1$/)
      titles << [line_no, $1.length, $2]
      start ||= line_no
    end
  end

  last_section = nil
  last_level = nil

  # Second pass: Iterate over all matched titles and compute their
  # corresponding section numbers. Then replace the titles with
  # annotated anchors.
  titles.each do |title_info|
    line_no, level, text = title_info

    if last_section
      section = last_section.dup

      if last_level < level
        section << 1
      else
        (last_level - level).times { section.pop }
        section[-1] += 1
      end
    else
      section = [1]
    end

    name = section.join(".")
    lines[line_no] = %(#{"#" * level} <a name="section_#{name}"></a> #{name} #{text})

    title_info << section
    last_section = section
    last_level = level
  end

  # Third pass: Iterate over matched titles once more to produce the
  # table of contents. Then insert it immediately above the first
  # matched title.
  if start
    toc = titles.map do |(line_no, level, text, section)|
      name = section.join(".")
      %(#{" " * (section.length * 3)}* [#{name} #{text}](#section_#{name}))
    end + [""]

    lines.insert(start, *toc)
  end

  lines.join("\n")
end

if __FILE__ == $0
  puts mdtoc($<.read)
end
