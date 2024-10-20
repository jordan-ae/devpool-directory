import { Statistics } from "../types/statistics";
import { DEVPOOL_OWNER_NAME, DEVPOOL_REPO_NAME, GitHubIssue, octokit } from "./directory";
let gitChanges: Array<{ path: string; content: string }> = [];

export async function getDefaultBranch(owner: string, repo: string): Promise<string> {
  try {
    const { data } = await octokit.rest.repos.get({
      owner,
      repo,
    });
    return data.default_branch;
  } catch (error) {
    console.error(`Error fetching default branch: ${error}`);
    throw error;
  }
}

async function gitCommit(data: unknown, fileName: string) {
  try {
    gitChanges.push({
      path: fileName,
      content: JSON.stringify(data),
    });
  } catch (error) {
    console.error(`Error stringifying data for ${fileName}:`, error);
    throw error;
  }
}

import { Octokit } from "@octokit/rest";
import { TwitterMap } from "./initialize-twitter-map";

const MAX_PAYLOAD_SIZE = 100000000; // 100MB per commit, adjust as needed

export async function gitPush() {
  if (gitChanges.length === 0) {
    console.log("No changes to commit");
    return;
  }

  try {
    const owner = DEVPOOL_OWNER_NAME;
    const repo = DEVPOOL_REPO_NAME;
    const branch = await getDefaultBranch(owner, repo);
    const { data: refData } = await octokit.rest.git.getRef({
      owner,
      repo,
      ref: `heads/${branch}`,
    });
    const latestCommitSha = refData.object.sha;

    let currentChanges: Array<{ path: string; content: string }> = [];
    let currentSize = 0;

    for (const change of gitChanges) {
      const changeSize = Buffer.byteLength(change.content, "utf8");
      if (currentSize + changeSize > MAX_PAYLOAD_SIZE) {
        await commitChanges(octokit, owner, repo, branch, latestCommitSha, currentChanges);
        currentChanges = [];
        currentSize = 0;
      }
      currentChanges.push(change);
      currentSize += changeSize;
    }

    if (currentChanges.length > 0) {
      await commitChanges(octokit, owner, repo, branch, latestCommitSha, currentChanges);
    }

    // Clear the changes after successful push
    gitChanges = [];
  } catch (error) {
    console.error("Error committing changes:", error);
    throw error;
  }
}

async function commitChanges(
  octokit: Octokit,
  owner: string,
  repo: string,
  branch: string,
  baseSha: string,
  changes: Array<{ path: string; content: string }>
) {
  if (changes.length === 0) return;

  // Create tree for the changes
  const { data: treeData } = await octokit.rest.git.createTree({
    owner,
    repo,
    base_tree: baseSha,
    tree: changes.map((change) => ({
      path: change.path,
      mode: "100644",
      type: "blob",
      content: change.content,
    })),
  });

  // Create commit
  const { data: commitData } = await octokit.rest.git.createCommit({
    owner,
    repo,
    message: "chore: update files",
    tree: treeData.sha,
    parents: [baseSha],
  });

  // Update the reference to point to the new commit
  await octokit.rest.git.updateRef({
    owner,
    repo,
    ref: `heads/${branch}`,
    sha: commitData.sha,
  });

  console.log(`Committed to ${branch}: ${commitData.sha}`);
}

export async function commitStatistics(statistics: Statistics) {
  try {
    await gitCommit(statistics, "devpool-statistics.json");
  } catch (error) {
    console.error(`Error preparing devpool statistics for github file: ${error}`);
  }
}

export async function commitTasks(tasks: GitHubIssue[]) {
  try {
    await gitCommit(tasks, "devpool-issues.json");
  } catch (error) {
    console.error(`Error preparing devpool issues for github file: ${error}`);
  }
}

export async function commitTwitterMap(twitterMap: TwitterMap) {
  try {
    await gitCommit(twitterMap, "twitter-map.json");
  } catch (error) {
    console.error(`Error preparing twitter map for github file: ${error}`);
  }
}
