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
      ]
    }
  ]
}

resource "github_repository" "example" {
  for_each = {for repo in var.repos: repo.name => repo}
  name = each.value.name
  description = each.value.description
}

resource "github_membership" "example" {
  for_each = {for user in var.users: user.username => user}
  username = each.value.username
  role     = each.value.role
}

resource "github_team" "example" {
  for_each = {for team in var.teams: team.name => team}
  name        = each.value.name
  description = each.value.description
  privacy     = each.value.privacy
}

#resource "github_team_membership" "example" {
#  for_each = {for user in var.users: user.username => user}
#  team_id  = "${github_team.some_team.id}"
#  username = "SomeUser"
#  role     = "member"
#}