defmodule ChatAppWeb.RoomController do
  use ChatAppWeb, :controller

  alias ChatApp.Talk
  alias ChatApp.Talk.Room

  plug ChatAppWeb.Plugs.AuthenticateUser when action not in [:index]
  plug :authorize_user when action in [:edit, :update, :delete]

  def index(conn, _params) do
    rooms = Talk.list_rooms()
    render(conn, "index.html", rooms: rooms)
  end

  def new(conn, _params) do
    changeset = Room.changeset(%Room{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"room" => room_params}) do
    case Talk.create_room(conn.assigns.current_user, room_params) do
      {:ok, _room} ->
        conn
        |> put_flash(:info, "Room Created")
        |> redirect(to: Routes.room_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    room = Talk.get_room!(id)
    render(conn, "show.html", room: room)
  end

  def edit(conn, %{"id" => id}) do
    room = Talk.get_room!(id)
    changeset =  Talk.change_room(room)
    render(conn, "edit.html", room: room, changeset: changeset)
  end

  def update(conn, %{"id" => id, "room" => room_params}) do
    room = Talk.get_room!(id)
    case Talk.update_room(room, room_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Room Info Updated!")
        |> redirect(to: Routes.room_path(conn, :show, room))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("edit.html", room: room, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Talk.delete_room(id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Room Deleted")
        |> redirect(to: Routes.room_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:info, "Room not Deleted!")
        |> redirect(to: Routes.room_path(conn, :show, id))
    end
  end

  defp authorize_user(conn, _) do
    %{params: %{"id" => room_id}} = conn
    room = Talk.get_room!(room_id)

    if conn.assigns.current_user.id == room.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized")
      |> redirect(to: Routes.room_path(conn, :index))
      |> halt()
    end
  end
end
