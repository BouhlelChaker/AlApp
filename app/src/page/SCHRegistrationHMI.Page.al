page 51000 "SCH Registration HMI"
{
    Caption = 'Registration';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Posting,Prepare,Order,Request Approval,History,Print/Send,Navigate';
    RefreshOnActivate = true;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "SCH Registration HMI";

    AboutTitle = 'About registration details';
    AboutText = 'Choose the registration details and fill in registration with speciality to be studied.';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                }
                field("Customer No."; "Customer No.")
                {

                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer No.';
                    Importance = Additional;
                    NotBlank = true;
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default.';

                }

                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer Name';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the customer who will receive the products and be billed by default.';

                    AboutTitle = 'Who are you selling to?';
                    AboutText = 'You can choose existing customers, or add new customers when you create orders. Orders can automatically choose special prices and discounts that you have set for each customer.';

                    trigger OnValidate()
                    begin
                    end;
                }
                field("Item No."; "Item No.")
                {

                    ApplicationArea = Basic, Suite;
                    Caption = 'Item No.';
                    Importance = Additional;
                    NotBlank = true;
                    ToolTip = 'Specifies the number of the Item.';

                }

                field("Item Description"; "Item Description")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Description';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                    end;
                }

                field("Item Description 2"; "Item Description 2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Description 2';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                    end;
                }
                field("Total Amount Excl. VAT"; "Total Amount Excl. VAT")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '"Total Amount Excl. VAT"';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                    end;
                }
                field("Total Amount Incl. VAT"; "Total Amount Incl. VAT")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '"Total Amount Incl. VAT"';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                    end;
                }

            }
        }
    }

}