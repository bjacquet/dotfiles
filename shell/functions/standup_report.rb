#!/usr/bin/env ruby
# frozen_string_literal: true

# Converts markdown-style todo lines into Slack emoji todo lines.
# Any header text before the first todo item is removed.
#
# Usage:
#   ruby todo2slack.rb <input>

Encoding.default_external = Encoding::UTF_8


AT_MENTION = /(?<!\S)@(?=\w)/
COLOUR_CODE = /\e?\[[0-9;]*m/

def clean(line)
  line.chomp.gsub(COLOUR_CODE, "").gsub(AT_MENTION, "")
end


BULLET = /\A(?<indent>\s*)[-*]\s+(?<rest>.*)\z/
CHECKBOX = /\A\[(?<mark>.)\]\s+(?<text>.*)\z/
EMOJIS = {
  "."  => ":todo_doing:",
  "X"  => ":todo_done:",
  "x"  => ":todo_done:",
  " "  => ":todo:",
  "-"  => ":todo_paused:"
}.freeze
STRIKE_THROUGH = /\A~+(?<inner>.*?)~+\z/

def convert(line)
  bullet = BULLET.match(line)
  return line unless bullet

  indent = bullet[:indent]
  checkbox = CHECKBOX.match(bullet[:rest])
  return "#{indent}* #{bullet[:rest]}" unless checkbox && EMOJIS.key?(checkbox[:mark])

  text = checkbox[:text]
  if (cancelled = text.match(STRIKE_THROUGH))
    return "#{indent}:todo_cancel: #{cancelled[:inner]}"
  end

  "#{indent}#{EMOJIS[checkbox[:mark]]} #{text}"
end


# Skip any header text; output starts at the first bullet item.
ARGF.each_line.map { |line| clean(line) }
    .drop_while { |line| !BULLET.match?(line) }
    .each { |line| puts convert(line) }
