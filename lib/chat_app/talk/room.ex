defmodule ChatApp.Talk.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChatApp.Talk.Room

  schema "rooms" do
    field :description, :string
    field :name, :string
    field :topic, :string

    belongs_to :user, ChatApp.Accounts.User
    has_many :message, ChatApp.Talk.Message

    timestamps()
  end

  @doc false
  def changeset(%Room{} = room, attrs) do
    room
    |> cast(attrs, [:name, :description, :topic])
    |> validate_required([:name, :topic])
    |> unique_constraint(:name)
    |> validate_length(:name, min: 5, max: 30)
    |> validate_length(:topic, min: 5, max: 120)
  end
end
