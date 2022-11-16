import EctoEnum

defenum(TrelloCloneClient.PermissionType, :permission_type, [
  :manage,
  :write,
  :read
])

defenum(TrelloCloneClient.TaskStatus, :status, [
  :not_started,
  :in_progress,
  :for_review,
  :blocked,
  :done
])
