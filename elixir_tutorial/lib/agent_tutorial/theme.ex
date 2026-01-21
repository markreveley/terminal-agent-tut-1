defmodule AgentTutorial.Theme do
  @moduledoc """
  Terminal color theme and visual constants for the tutorial.

  Uses ANSI 256 color codes compatible with Termite.
  """

  # ANSI 256 color codes
  # Primary colors
  def primary, do: 135      # Violet (purple)
  def secondary, do: 44     # Cyan
  def accent, do: 214       # Amber/Orange

  # Status colors
  def success, do: 42       # Green
  def error, do: 196        # Red
  def warning, do: 214      # Amber
  def info, do: 33          # Blue

  # Text colors
  def text, do: 252         # Light gray
  def text_muted, do: 245   # Muted gray
  def text_dim, do: 240     # Dim gray

  # Box drawing characters
  def box do
    %{
      top_left: "┌",
      top_right: "┐",
      bottom_left: "└",
      bottom_right: "┘",
      horizontal: "─",
      vertical: "│",
      tee_right: "├",
      tee_left: "┤",
      tee_down: "┬",
      tee_up: "┴",
      cross: "┼"
    }
  end

  # Progress bar characters
  def progress do
    %{
      filled: "█",
      partial: "▓",
      light: "░",
      empty: "░"
    }
  end

  # Status icons
  def icons do
    %{
      check: "✅",
      cross: "❌",
      warning: "⚠️",
      info: "ℹ️",
      arrow: "→",
      bullet: "•",
      star: "★",
      folder: "📁",
      file: "📄",
      code: "💻",
      robot: "🤖",
      shell: "🐚",
      beam: "🧬",
      lightning: "⚡"
    }
  end

  @doc """
  Apply foreground color to text using Termite.Style
  """
  def colored(text, color_code) do
    Termite.Style.foreground(color_code)
    |> Termite.Style.render_to_string(text)
  end

  @doc """
  Apply bold styling to text
  """
  def bold(text) do
    Termite.Style.bold()
    |> Termite.Style.render_to_string(text)
  end

  @doc """
  Apply bold and color to text
  """
  def bold_colored(text, color_code) do
    Termite.Style.bold()
    |> Termite.Style.foreground(color_code)
    |> Termite.Style.render_to_string(text)
  end

  @doc """
  Create a progress bar string
  """
  def progress_bar(value, max \\ 100, width \\ 40) do
    percentage = min(100, max(0, value / max * 100))
    filled_width = round(percentage / 100 * width)
    empty_width = width - filled_width

    p = progress()
    filled = String.duplicate(p.filled, filled_width)
    empty = String.duplicate(p.empty, empty_width)

    color = cond do
      percentage > 80 -> error()
      percentage > 50 -> warning()
      true -> success()
    end

    "[" <> colored(filled, color) <> colored(empty, text_dim()) <> "] #{round(percentage)}%"
  end

  @doc """
  Draw a horizontal line
  """
  def horizontal_line(width \\ 60) do
    String.duplicate(box().horizontal, width)
  end
end
