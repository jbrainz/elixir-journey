defmodule Servy.BearController do
  alias Servy.Wildthings
  @templates_path Path.expand("../../templates", __DIR__)

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&(&1.name <= &2.name))

    render_content(conv, "index.eex", bears: bears)
  end

  defp render_content(conv, path, bindings \\ []) do
    content =
      @templates_path
      |> Path.join(path)
      |> EEx.eval_file(bindings)

    %{conv | status: 200, resp_body: content}
  end

  def get_bear(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    render_content(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type} = _) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}"}
  end
end
