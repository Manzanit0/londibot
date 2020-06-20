defmodule LondibotWeb.DashboardView do
  use LondibotWeb, :view

  import Ecto.Query

  def disruptions_data(_conn) do
    query =
      from c in "status_changes",
        where: c.new_status != "Good Service" and c.new_status != "Service Closed",
        select: {
          row_number() |> over(order_by: [desc: count(c.id)]),
          c.tfl_line,
          count(c.id)
        },
        group_by: c.tfl_line,
        order_by: [desc: count(c.id)]

    query
    |> Londibot.Repo.all()
    |> append_max_count()
    |> custom_crop_names()
  end

  defp append_max_count([]), do: []

  defp append_max_count(records) do
    max =
      records
      |> Enum.map(fn {_index, _line, count} -> count end)
      |> Enum.max()

    Enum.map(records, fn {row, line, count} -> {row, line, count, max} end)
  end

  defp custom_crop_names(records), do: Enum.map(records, &crop_name/1)

  defp crop_name({_, "London Overground", _, _} = r), do: put_elem(r, 1, "Overground")
  defp crop_name({_, "Hammersmith & City", _, _} = r), do: put_elem(r, 1, "Ham. & City")
  defp crop_name({_, "Waterloo & City", _, _} = r), do: put_elem(r, 1, "Wat. & City")
  defp crop_name(record), do: record

  # Height of the chart in pixels
  def max_height, do: 300
  def bar_width, do: 35

  # Rule of three formula. We don't want the height to be
  # higher than the chart's height.
  # Also, make all bars 20% lower than the actual total
  # height of the chart.
  def bar_height(max_count, current_count, chart_height),
    do: chart_height * current_count * 0.8 / max_count

  # Since SVG bars (x, y) coordinates start at the top-left corner,
  # To make them seem like they start at the bottom, lower them the difference.
  def bar_y(max_count, current_count, chart_height),
    do: chart_height - bar_height(max_count, current_count, chart_height)

  def text_y(max_count, current_count, chart_height),
    do: chart_height - max_count * 2 - current_count / 2

  # Since we want bars and text aligned, we give them
  # the same 'x' value. 40 is kind of magical ¯\_(ツ)_/¯.
  def bar_x(position),
    do: position * 40

  def text_x(position),
    do: position * 40

  # Same applies for the transform. Magical playing ¯\_(ツ)_/¯.
  def text_transform(current_count, position) do
    translate_value = 70 - current_count * 1.5
    rotate_x = text_x(position)
    rotate_y = 70 - current_count / 2
    "translate(180, #{translate_value}) rotate(-45, #{rotate_x}, #{rotate_y})"
  end

  # Some resources to understand the above:
  # - https://css-tricks.com/transforms-on-svg-elements/
  # - https://css-tricks.com/how-to-make-charts-with-svg/
end
