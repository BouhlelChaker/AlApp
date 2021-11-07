page 51001 "SCH Registration List HMI"
{

    ApplicationArea = Basic, Suite, Service;
    Caption = 'Registrations';
    CardPageID = "SCH Registration HMI";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Approve,New Document,Request Approval,Customer,Navigate,Prices & Discounts';
    QueryCategory = 'Registration List';
    RefreshOnActivate = true;
    SourceTable = "SCH Registration HMI";
    UsageCategory = Lists;

    AboutTitle = 'About registrations';
    AboutText = 'Here you overview all registrations.';

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    //ToolTip = 'Specifies the ';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    //ToolTip = 'Specifies the ';
                }
            }
        }
    }
}