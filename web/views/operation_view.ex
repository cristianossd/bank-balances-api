defmodule PhoenixDocker.OperationView do
  use PhoenixDocker.Web, :view

  def render("index.json", _) do
    %{success: "Successfully connected"}
  end

  def render("created.json", _) do
    %{success: :ok}
  end
end
