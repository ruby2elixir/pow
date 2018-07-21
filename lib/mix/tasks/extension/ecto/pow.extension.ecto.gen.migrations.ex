defmodule Mix.Tasks.Pow.Extension.Ecto.Gen.Migrations do
  @shortdoc "Generates user extension migration files"

  @moduledoc """
  Generates a migration files for extensions.

      mix pow.extension.ecto.gen.migrations -r MyApp.Repo
  """
  use Mix.Task

  alias Pow.Extension.Ecto.Schema.Migration, as: SchemaMigration
  alias Mix.{Ecto, Pow, Pow.Ecto.Migration, Pow.Extension}

  @switches [binary_id: :boolean, extension: :keep]
  @default_opts [binary_id: false]

  @doc false
  def run(args) do
    Pow.no_umbrella!("pow.extension.ecto.gen.migrations")

    args
    |> Pow.parse_options(@switches, @default_opts)
    |> create_migrations_files(args)
  end

  defp create_migrations_files(config, args) do
    args
    |> Ecto.parse_repo()
    |> Enum.map(&Ecto.ensure_repo(&1, args))
    |> Enum.map(&Map.put(config, :repo, &1))
    |> Enum.each(&create_extension_migration_files/1)
  end

  defp create_extension_migration_files(config) do
    extensions   = Extension.extensions(config)
    context_base = Pow.context_base(Pow.context_app())

    for extension <- extensions,
      do: create_migration_files(config, extension, context_base)
  end

  defp create_migration_files(%{repo: repo, binary_id: binary_id}, extension, context_base) do
    name    = SchemaMigration.name(extension, "users")
    content = SchemaMigration.gen(extension, context_base, repo: repo, binary_id: binary_id)

    Migration.create_migration_files(repo, name, content)
  end
end
