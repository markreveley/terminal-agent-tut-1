defmodule AgentTutorial.Components.UI do
  @moduledoc """
  Reusable UI components for the terminal tutorial.
  """

  alias AgentTutorial.Theme

  @doc """
  Render a framed box with optional title
  """
  def framed_box(content, opts \\ []) do
    title = Keyword.get(opts, :title)
    width = Keyword.get(opts, :width, 60)
    color = Keyword.get(opts, :color, Theme.primary())

    box = Theme.box()
    inner_width = width - 2

    top_border = if title do
      title_str = " #{title} "
      padding = inner_width - String.length(title_str) - 1
      box.top_left <> box.horizontal <> title_str <> String.duplicate(box.horizontal, max(0, padding)) <> box.top_right
    else
      box.top_left <> String.duplicate(box.horizontal, inner_width) <> box.top_right
    end

    bottom_border = box.bottom_left <> String.duplicate(box.horizontal, inner_width) <> box.bottom_right

    # Wrap content lines
    content_lines = content
    |> String.split("\n")
    |> Enum.map(fn line ->
      padded = String.pad_trailing(line, inner_width - 2)
      box.vertical <> " " <> padded <> " " <> box.vertical
    end)
    |> Enum.join("\n")

    Theme.colored(top_border, color) <> "\n" <>
    content_lines <> "\n" <>
    Theme.colored(bottom_border, color)
  end

  @doc """
  Render a lesson header
  """
  def lesson_header(lesson_number, title) do
    header = Theme.bold_colored("LESSON #{lesson_number}:", Theme.accent()) <>
             " " <>
             Theme.bold_colored(String.upcase(title), Theme.text())

    header <> "\n" <> Theme.colored(Theme.horizontal_line(), Theme.text_dim())
  end

  @doc """
  Render navigation hints
  """
  def navigation_hints(hints) do
    hints
    |> Enum.map(fn {key, action} ->
      Theme.colored("[#{key}]", Theme.secondary()) <> " " <> Theme.colored(action, Theme.text_muted())
    end)
    |> Enum.join("  ")
  end

  @doc """
  Render a concept list with bullets
  """
  def concept_list(title, concepts) do
    icons = Theme.icons()
    header = Theme.bold_colored(title, Theme.info())

    items = concepts
    |> Enum.map(fn concept ->
      "  " <> icons.bullet <> " " <> Theme.colored(concept, Theme.text_muted())
    end)
    |> Enum.join("\n")

    header <> "\n" <> items
  end

  @doc """
  Render a comparison table
  """
  def comparison_table(headers, rows) do
    {h1, h2} = headers
    col_width = 28

    header_line = Theme.bold_colored(String.pad_trailing(h1, col_width), Theme.accent()) <>
                  Theme.bold_colored(String.pad_trailing(h2, col_width), Theme.success())

    separator = Theme.colored(String.duplicate("─", col_width * 2), Theme.text_dim())

    row_lines = rows
    |> Enum.map(fn {c1, c2} ->
      Theme.colored(String.pad_trailing(c1, col_width), Theme.text_muted()) <>
      Theme.colored(String.pad_trailing(c2, col_width), Theme.text())
    end)
    |> Enum.join("\n")

    header_line <> "\n" <> separator <> "\n" <> row_lines
  end

  @doc """
  Render a code block
  """
  def code_block(code, _language \\ nil) do
    box = Theme.box()
    lines = String.split(code, "\n")

    max_width = lines
    |> Enum.map(&String.length/1)
    |> Enum.max()
    |> max(40)

    width = max_width + 4

    top = box.top_left <> String.duplicate(box.horizontal, width - 2) <> box.top_right
    bottom = box.bottom_left <> String.duplicate(box.horizontal, width - 2) <> box.bottom_right

    content = lines
    |> Enum.map(fn line ->
      padded = String.pad_trailing(line, width - 4)
      box.vertical <> " " <> Theme.colored(padded, Theme.secondary()) <> " " <> box.vertical
    end)
    |> Enum.join("\n")

    Theme.colored(top, Theme.text_dim()) <> "\n" <>
    content <> "\n" <>
    Theme.colored(bottom, Theme.text_dim())
  end

  @doc """
  Render a highlighted text block
  """
  def highlight(text, type \\ :primary) do
    color = case type do
      :primary -> Theme.primary()
      :success -> Theme.success()
      :warning -> Theme.warning()
      :error -> Theme.error()
      :info -> Theme.info()
      _ -> Theme.text()
    end

    Theme.bold_colored(text, color)
  end

  @doc """
  Render a success/check item
  """
  def check_item(title, description) do
    icons = Theme.icons()
    Theme.colored(icons.check <> " " <> title, Theme.success()) <> "\n" <>
    "     " <> Theme.colored(description, Theme.text_muted())
  end

  @doc """
  Render an error/cross item
  """
  def cross_item(title, description) do
    icons = Theme.icons()
    Theme.colored(icons.cross <> " " <> title, Theme.error()) <> "\n" <>
    "     " <> Theme.colored(description, Theme.text_muted())
  end
end
