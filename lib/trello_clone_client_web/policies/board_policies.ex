defmodule TrelloCloneClientWeb.Policies.BoardPolicies do

  def policy(assigns, identifier) when identifier == :read_board do
    case assigns[:board_permission] do
      nil -> {:error, :forbidden}
      board_permission ->
        if board_permission.permission_type in [:manage, :write, :read] do
          :ok
        else
          {:error, :forbidden}
        end
    end
  end

  def policy(assigns, identifier) when identifier == :update_board do
    case assigns[:board_permission] do
      nil -> {:error, :forbidden}
      board_permission ->
        if board_permission.permission_type in [:manage, :write] do
          :ok
        else
          {:error, :forbidden}
        end
    end
  end

  def policy(assigns, identifier) when identifier == :manage_board do
    case assigns[:board_permission] do
      nil -> {:error, :forbidden}
      board_permission ->
        if board_permission.permission_type == :manage do
          :ok
        else
          {:error, :forbidden}
        end
    end
  end


  def policy(_assigns, _identifier), do: {:error, :forbidden}
end
