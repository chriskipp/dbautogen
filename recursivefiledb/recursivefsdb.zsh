#!/bin/zsh
 
#===============================================
# Defining Variables
DB_PATH="${PWD}/filetree.db"
SOURCEDIR="${HOME}"
BATCH_SIZE=1000
#===============================================

#===============================================
# If "pv" is installed use pv else cat
if which pv 2>&1 >/dev/null; then
  PVCMD="pv -l -i 0.1"
else
  PVCMD="cat"
fi
#===============================================

# Defining printf strings for the find command
# (Must be on one line!)
INSERTSTR_DIRS='INSERT INTO dNode ( inode, label) VALUES ( %i, "%p");\n'
INSERTSTR_ALLPATHS='INSERT INTO Node ( inode, label, parent_label, name) VALUES ( %i, "%p", "%h", "%f");\n'
#===============================================

#===============================================
# Functions
#===============================================
function bufferstream() {
  #===============================================
  # USAGE: bufferstream BATCH_SIZE BEGIN_STRING END_STRING
  #
  # Reads stream from stdin
  #===============================================
  BATCH_SIZE="${1}"
  BEGIN_STRING="${2}"
  END_STRING="${3}"
  split --lines="${BATCH_SIZE}" --filter "(
    printf '${BEGIN_STRING}\n'; cat -; printf '${END_STRING}\n'
  )"
}

function create_recursivefsdb() {
  #===============================================
  # USAGE: create_recursivefsdb
  #===============================================
  (
    printf '
    
    PRAGMA recursive_triggers = TRUE;

      CREATE TABLE IF NOT EXISTS dNode (
        inode INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT);
  
      CREATE TABLE IF NOT EXISTS Node (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        inode INTEGER,
        label TEXT,
        parent_label TEXT,
        name TEXT
      );
  
      CREATE INDEX IF NOT EXISTS labels ON dnode (label);
  
  ' ) | sqlite3 "${DB_PATH}"
  
  (
    find "${SOURCEDIR}" -type d -printf "${INSERTSTR_DIRS}"
    find "${SOURCEDIR}" -printf "${INSERTSTR_ALLPATHS}"
  ) | sed "s/'/''/g" \
    | bufferstream "${BATCH_SIZE}" 'BEGIN TRANSACTION;' 'COMMIT;' \
    | "${PVCMD}" \
    | sqlite3 "${DB_PATH}" 2>"error.log"
  
  printf 'CREATE TABLE iNodes AS
    SELECT n.inode,
          n.name,
          d.inode as pinode
        FROM Node AS n
        LEFT JOIN dNode as d
        ON n.parent_label = d.label;
  
    DROP TABLE Node; DROP TABLE dNode;
  
    CREATE INDEX fd_idx ON `iNodes` (inode, pinode);
    CREATE INDEX df_idx ON `iNodes` (pinode, inode); 
  ' | sqlite3 "${DB_PATH}"
  printf 'VACUUM;' | sqlite3 "${DB_PATH}"
}
    
    
function get_inode() {
  #===============================================
  # Gets the inode of a given path
  #
  # USAGE: get_inode [ PATH ]
  #===============================================
  if [ "${#}" -gt 0 ]; then
    find "${1}" -maxdepth 0 -printf '%i, "%f"'
  else
    find "${PWD}" -maxdepth 0 -printf '%i, "%f"'
  fi
}

function get_filepaths() {
  #===============================================
  # Prints the combinded paths of the file system
  # below a given PATH or the current directory
  #
  # USAGE: get_filepaths [ PATH ]
  #===============================================
  if [ "${#}" -gt 0 ]; then
	FSLOCATION=$(get_inode "${1}")
  else
  	FSLOCATION=$(get_inode "${PWD}")
  fi

  printf "
  WITH RECURSIVE
    under_directory(inode, label, level) AS (
      VALUES(${FSLOCATION}, 0)
      UNION ALL
      SELECT
        iNodes.inode,
        under_directory.label || '/' || iNodes.name AS label,
	under_directory.level + 1 AS level
        FROM iNodes
      JOIN under_directory
        ON iNodes.pinode = under_directory.inode
      ORDER BY 3 DESC
    )
  SELECT a.inode || '\t' || a.label
  FROM under_directory AS a
  INNER JOIN iNodes AS i
    ON i.inode = a.inode ;"  | sqlite3 "${DB_PATH}"
}

function get_filesystem_tree() {
  #===============================================
  # Prints a tree of the file system below a given
  # PATH or the current directory
  #
  # USAGE: get_filesystem_tree [ PATH ]
  #===============================================
  if [ "${#}" -gt 0 ]; then
	FSLOCATION=$(get_inode "${1}")
  else
  	FSLOCATION=$(get_inode "${PWD}")
  fi

  printf "
  WITH RECURSIVE
    under_directory(inode, label, level, tree) AS (
      VALUES(${FSLOCATION}, 0, '├──')
      UNION ALL
      SELECT
        iNodes.inode,
        iNodes.name AS label,
        under_directory.level + 1,
	'│  ' || under_directory.tree AS tree
        FROM iNodes
      JOIN under_directory
        ON iNodes.pinode = under_directory.inode
      ORDER BY 3 DESC
    )
  SELECT a.tree || a.label
  FROM under_directory AS a
  INNER JOIN iNodes AS i
    ON i.inode = a.inode ;"  | sqlite3 "${DB_PATH}"
}

