########################################################################
# :timer:slurm
########################################################################

function :timer:slurm
{
   local Remaining

   REPLY=

   [[ -n ${SLURM_JOB_ID-} ]] || return 1
   whence -p squeue >/dev/null 2>&1 || return 1

   Remaining=$(
      command squeue \
         -h \
         -j "$SLURM_JOB_ID" \
         -o '%L' 2>/dev/null
   )

   [[ -n $Remaining ]] || return 1

   REPLY=$Remaining
}
