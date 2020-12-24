defmodule Utility.Storage do
  @type generator :: %Utility.GenDiff.Generator{}
  @type html :: Path.t()

  @callback get(generator) :: {:ok, html} | {:error, term}
  @callback put(generator, html) :: :ok | {:error, term}

  defp impl(), do: Application.get_env(:utility, :storage)

  def get(project, id) do
    impl().get(project, id)
  end

  def put(generator, html) do
    impl().put(generator.project, generator.id, html)
  end
end
