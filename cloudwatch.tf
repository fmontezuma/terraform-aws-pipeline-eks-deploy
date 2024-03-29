data "aws_codecommit_repository" "repo" {
  repository_name = "${var.project_name}-k8s-deploy"
}

resource "aws_cloudwatch_event_rule" "rule" {
  name = "${var.project_name}-k8s-deploy-${var.env}"
  role_arn = var.codepipeline_role_arn
  event_pattern = <<PATTERN
{
	"source":["aws.codecommit"],
	"detail-type":["CodeCommit Repository State Change"],
	"resources":["${data.aws_codecommit_repository.repo.arn}"],
	"detail":{
        "event": [
          "referenceCreated",
          "referenceUpdated"
        ],
		"referenceType":["branch"],
		"referenceName":["${var.env}"]
	}
}
PATTERN
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rule.name
  arn       = aws_codepipeline.codepipeline.arn
  role_arn = var.codepipeline_role_arn
}
