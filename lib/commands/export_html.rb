require_relative '../command'
require_relative '../session'

class ExportHtml < Command
  def matches?(line)
    line.split.first == "x"
  end

  def process(line, session)
    list = session.foreground_tasks
    args = line.split.drop(1)
    section_name = args.join(' ') unless args.empty?

    if section_name
      idx = list.find_section_by_name(section_name)
      return unless idx
      items = list.instance_variable_get(:@items)
      section = items[idx]
      html = build_section_html(section)
      filename = section.name + ".html"
    else
      html = build_html(list)
      filename = "todo.html"
    end

    path = File.expand_path("~/#{filename}")
    File.write(path, html)
    list.io.display_paginated("Wrote #{path}\n")
    list.io.get_from_console
  end

  def description
    CommandDesc.new("x [section]", "export foreground list (or section) as HTML")
  end

  private

  def build_html(list)
    items = list.instance_variable_get(:@items)

    body = ""
    items.each_with_index do |item, i|
      if item.section?
        label = i.to_s
        name = esc(item.name)
        children_html = item.children.map.with_index do |child, j|
          child_label = "#{i}.#{j + 1}"
          "<div class=\"item child\"><span class=\"label\">#{esc(child_label)}</span>#{task_content(child.text.chomp)}</div>"
        end.join("\n")
        open_attr = item.collapsed ? "" : " open"
        body << <<~SECTION
          <details class="section"#{open_attr}>
            <summary class="item section-header"><span class="label">#{esc(label)}</span>#{name}</summary>
            #{children_html}
          </details>
        SECTION
      else
        label = i.to_s
        body << "<div class=\"item top\"><span class=\"label\">#{esc(label)}</span>#{task_content(item.text.chomp)}</div>\n"
      end
    end

    wrap_html("Todo", body)
  end

  def build_section_html(section)
    body = section.children.map.with_index do |child, j|
      "<div class=\"item\"><span class=\"label\">#{esc((j + 1).to_s)}</span>#{task_content(child.text.chomp)}</div>"
    end.join("\n")

    wrap_html(esc(section.name), body)
  end

  def wrap_html(title, body)
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>#{title}</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { background: #1e1e2e; color: #cdd6f4; font-family: 'SF Mono', 'Menlo', 'Monaco', monospace; font-size: 14px; padding: 20px; }
          .item { padding: 8px 12px; white-space: nowrap; }
          .section-header { color: #89b4fa; font-weight: bold; list-style: none; -webkit-tap-highlight-color: transparent; }
          .section-header::-webkit-details-marker { display: none; }
          details .section-header::before { content: '\\25B8 '; color: #6c7086; }
          details[open] .section-header::before { content: '\\25BE '; color: #6c7086; }
          .item.top::before { content: '\\25B8 '; color: transparent; }
          .child { padding-left: 36px; }
          .label { color: #6c7086; display: inline-block; width: 48px; text-align: right; margin-right: 8px; }
          .tag { color: #f5c2e7; font-weight: bold; display: inline-block; width: 1.5ch; }
        </style>
      </head>
      <body>
        #{body}
      </body>
      </html>
    HTML
  end

  def task_content(text)
    "<span class=\"tag\">#{esc(tag_of(text).to_s)}</span>#{esc(strip_tag(text))}"
  end

  def tag_of(text)
    tokens = text.split
    tokens.first =~ /^[A-Z]:$/ && tokens.size > 1 ? tokens.first[0] : nil
  end

  def strip_tag(text)
    tokens = text.split
    tokens.first =~ /^[A-Z]:$/ && tokens.size > 1 ? tokens.drop(1).join(' ') : text
  end

  def esc(text)
    text.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub('"', "&quot;")
  end
end
