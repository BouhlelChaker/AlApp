table 51010 "SCH Schooling Setup HMI"
{
    Caption = 'Schooling Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(11; "Registration Nos."; Code[20])
        {
            Caption = 'Registration Nos.';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}