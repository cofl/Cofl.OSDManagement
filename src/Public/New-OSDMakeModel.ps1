<#
.SYNOPSIS
Creates a new Make/Model in the MDT database; does not create folders in the MDT configuration.

.DESCRIPTION
Creates a new Make/Model entry in the MDT database, with the supplied Task Sequence and Driver Group; it does not create the task sequence or the driver group.

.EXAMPLE
PS C:\> New-OSDMakeModel 'Dell' 'Optiplex 780' -TaskSequence 'SOME_TASK_SEQUENCE' -DriverGroup 'Windows\Optiplex 780'
Creates an entry for the Dell Optiplex 780 in the MDT database, and sets its default task sequence and driver group.
#>
function New-OSDMakeModel
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('OSDMakeModel')]
    PARAM (
        [Parameter(Mandatory=$true,Position=1)][Alias('Manufacturer')][ValidateNotNullOrEmpty()]
            # The manufacturer of the computer, as listed in the BIOS.
            [string]$Make,
        [Parameter(Mandatory=$true,Position=2)][ValidateNotNullOrEmpty()]
            # The model of the computer, as listed in the BIOS.
            [string]$Model,
        [Parameter(Mandatory=$true)][ValidateNotNull()]
            # A task sequence, either by object or ID.
            [TaskSequenceBinding]$TaskSequence,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
            # A driver group path (in MDT).
            [string]$DriverGroup
    )

    begin
    {
        Assert-OSDConnected
    }

    process
    {
        if(Get-OSDMakeModel -Model $Model -ErrorAction SilentlyContinue)
        {
            throw [InvalidOperationException]::new("Model ""$Model"" already exists.")
        }

        [OSDTaskSequence]$TaskSequenceObject = Resolve-TaskSequenceBinding -Bindings $TaskSequence

        if($PSCmdlet.ShouldProcess($Model, "Create"))
        {
            $Identity = Invoke-SQLQuery -Query @'
                set XACT_ABORT ON;
                begin transaction
                    declare @Identity int;
                    insert into MakeModelIdentity (Make, Model) VALUES (@Make, @Model);
                    set @Identity = SCOPE_IDENTITY();
                    insert into Settings (Type, ID, DriverGroup, TaskSequenceID, SkipTaskSequence) VALUES ('M', @Identity, @DriverGroup, @TaskSequenceID, 'YES');
                    select @Identity as ID;
                commit
'@ -Parameters @{
                '@Make' = $Make
                '@Model' = $Model
                '@DriverGroup' = $DriverGroup
                '@TaskSequenceID' = $TaskSequenceObject.ID
            } -Property ID
            Write-Verbose "Created MakeModel ""$Make $Model"" with ID $Identity"
            Get-OSDMakeModel -InternalID $Identity
        }
    }

    end
    {
        # update the caches, because we added a model.
        Update-OSDAutoCompleteCache
    }
}
