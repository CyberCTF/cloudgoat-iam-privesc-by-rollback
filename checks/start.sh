#!/bin/sh
# The starting user's access key works (it authenticates as Raynor), and Raynor's policy holds the
# five versions upstream's deploy step creates (v1 the default).
set -eu
arn=$(env -u AWS_SESSION_TOKEN -u AWS_PROFILE -u AWS_CREDENTIAL_EXPIRATION \
  AWS_ACCESS_KEY_ID="$ISOLOOM_OUTPUT_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$ISOLOOM_OUTPUT_SECRET_KEY" \
  aws sts get-caller-identity --query Arn --output text)
case "$arn" in */raynor-*) ;; *) echo "the key authenticates as $arn" >&2; exit 1 ;; esac
policy=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='cg-raynor-policy-isoloom'].Arn" --output text)
n=$(aws iam list-policy-versions --policy-arn "$policy" --query 'length(Versions)' --output text)
[ "$n" -eq 5 ] || { echo "$n policy versions, not 5" >&2; exit 1; }
