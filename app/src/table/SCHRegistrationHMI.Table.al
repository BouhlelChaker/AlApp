table 51000 "SCH Registration HMI"
{
    DataClassification = ToBeClassified;
    Caption = 'Registration';
    DataCaptionFields = "No.";
    LookupPageId = "SCH Registration List HMI";
    DrillDownPageID = "SCH Registration List HMI";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    //GetSalesSetup;
                    //NoSeriesMgt.TestManual(GetNoSeriesCode);
                    //"No. Series" := '';
                end;
            end;
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                GetCust("Customer No.");
                CopyCustomerInfoFieldsFromCustomer(Cust);

            end;
        }
        field(11; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            TableRelation = Customer.Name;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin

            end;
        }
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";

            trigger OnValidate()
            begin
                GetItm("Item No.");
                CopyItemInfoFieldsFromItem(Itm);

            end;
        }
        field(21; "Item Description"; Text[100])
        {
            Caption = 'Item description';
            TableRelation = Item.Description;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin

            end;
        }
        field(22; "Item Description 2"; Text[50])
        {
            Caption = 'Item description 2';
            TableRelation = Item."Description 2";
            ValidateTableRelation = false;

            trigger OnValidate()
            begin

            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    var
        Cust: Record Customer;
        Itm: Record Item;

    procedure GetCust(CustNo: Code[20]): Record Customer
    begin
        if (CustNo <> '') then begin
            if CustNo <> Cust."No." then
                Cust.Get(CustNo);
        end else
            Clear(Cust);

        exit(Cust);
    end;

    local procedure CopyCustomerInfoFieldsFromCustomer(var SellToCustomer: Record Customer)
    begin
        "Customer Name" := Cust.Name;
    end;

    procedure GetItm(ItmNo: Code[20]): Record Item
    begin
        if (ItmNo <> '') then begin
            if ItmNo <> Itm."No." then
                Itm.Get(ItmNo);
        end else
            Clear(Itm);

        exit(Itm);
    end;

    local procedure CopyItemInfoFieldsFromItem(var precItem: Record Item)
    begin
        "Item Description" := precItem.Description;
        "Item Description 2" := precItem."Description 2";
    end;

}