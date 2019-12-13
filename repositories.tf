provider "github" {
  organization = "Markieta-Inc"
}

variable "repos" {
  default = [
    {
      name = "repo1"
      description = "Repository 1"
    },
    {
      name = "repo2"
      description = "Repository 2"
    }
  ]
}

variable "users" {
  default = [
    {
      username = "Markieta2"
      role = "member"
    },
    {
      username = "Markieta3"
      role = "member"
    }
  ]
}

variable "teams" {
  default = [
    {
      name = "team1",
      description = "Team 1",
      privacy = "closed",
      users = [
        
      ],
      repos = [

      ]
    },
    {
      name = "team2",
      description = "Team 2",
      privacy = "closed",
      users = [
        {
          username = "Markieta2",
          role = "member"
        },
        {
          username = "Markieta3",
          role = "maintainer"
        }
      ],
      repos = [
        {
          name = "repo1",
          permission = "pull"
        },
        {
          name = "repo2",
          permission = "admin"
        }
      ]
    }
  ]
}

resource "github_repository" "example" {
  for_each = {
    for repo in var.repos:
    repo.name => repo
  }

  name = each.value.name
  description = each.value.description
}

resource "github_membership" "example" {
  for_each = {
    for user in var.users:
    user.username => user
  }

  username = each.value.username
  role     = each.value.role
}

resource "github_team" "example" {
  for_each = {
    for team in var.teams:
    team.name => team
  }

  name        = each.value.name
  description = each.value.description
  privacy     = each.value.privacy
}

locals {
  user_team_memberships = flatten([
    for team in var.teams: [
      for user in team.users: {
        team = team.name
        username = user.username
        role = user.role
      }
    ]
  ])
}

resource "github_team_membership" "example" {
  for_each = {
    for ut in local.user_team_memberships:
    "${ut.team}-${ut.username}" => ut
  }
  
  team_id  = github_team.example[each.value.team].id
  username = github_membership.example[each.value.username].username
  role     = each.value.role
}

locals {
  team_repositories = flatten([
    for team in var.teams: [
      for repo in team.repos: {
        team = team.name
        repo = repo.name
        permission = repo.permission
      }
    ]
  ])
}

resource "github_team_repository" "example" {
  for_each = {
    for tr in local.team_repositories:
    "${tr.team}-${tr.repo}" => tr
  }

  team_id    = github_team.example[each.value.team].id
  repository = github_repository.example[each.value.repo].id
  permission = each.value.permission
}