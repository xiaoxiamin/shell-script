logger.info("localclone hook triggered by ${user.username} for ${repository.name}")

def rootFolder = '/mnt/xvdb/www'
def bare = false
def cloneAllBranches = false
def cloneBranch = 'refs/heads/v2.0'
def includeSubmodules = true

def repoName = repository.name
def destinationFolder = new File(rootFolder, StringUtils.stripDotGit(repoName))
def srcUrl = 'file://' + new File(gitblit.getRepositoriesFolder(), repoName).absolutePath
//Process p = "cp -rf /mnt/xvdb/www/JiuYangPErp/public/files /mnt/xvdb/www/data".execute()  
//println "${p.text}"
// delete any previous clone
if (destinationFolder.exists()) {
	FileUtils.delete(destinationFolder, FileUtils.RECURSIVE)
}

// clone the repository
logger.info("cloning ${srcUrl} to ${destinationFolder}")
CloneCommand cmd = Git.cloneRepository();
cmd.setBare(bare)
if (cloneAllBranches)
	cmd.setCloneAllBranches(false)
else
	cmd.setBranch(cloneBranch)
cmd.setCloneSubmodules(includeSubmodules)
cmd.setURI(srcUrl)
cmd.setDirectory(destinationFolder)
Git git = cmd.call();
git.repository.close()
// report clone operation success back to pushing Git client
clientLogger.info("${repoName} cloned to ${destinationFolder}")
Process res = "sh /mnt/xvdb/www/script/v2.0.sh".execute()
//println "${p.text}"
