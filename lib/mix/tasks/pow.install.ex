defmodule Mix.Tasks.Pow.Install do
  @shortdoc "Generates pow module, user schema module, migrations file"

  @moduledoc """
  Generates a user schema module and migrations file by default

      mix pow.install -r MyApp.Repo
  """
  use Mix.Task

  alias Mix.Generator
  alias Mix.{Pow, Pow.Extension}
  alias Mix.Tasks.Pow.Ecto

  @switches [context_app: :string, extension: :keep]

  @doc false
  def run(args) do
    Pow.no_umbrella!("pow.install")

    args
    |> Pow.parse_options(@switches, [])
    |> create_pow_module()
    |> run_ecto_install(args)
  end

  defp create_pow_module(config) do
    context_app  = Map.get(config, :context_app, Pow.context_app())
    context_base = Pow.context_base(context_app)
    settings     = case Extension.extensions(config) do
      []         -> ""
      extensions -> ",
    extensions: #{inspect(extensions)}"
    end

    file_name = "pow.ex"
    content   = """
    defmodule #{context_base}.Pow do
      use Pow,
        user: #{context_base}.Users.User,
        repo: #{context_base}.Repo#{settings}
    end
    """

    context_app
    |> Pow.context_lib_path("")
    |> Path.join(file_name)
    |> Generator.create_file(content)

    config
  end

  defp run_ecto_install(config, args) do
    Ecto.Install.run(args)

    config
  end
end
