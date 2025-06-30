module Main.Forms.InfoWizardPage;

import std.typecons : RefCounted;

alias Functor = void delegate();

class InfoWizardPage : InfoWizardPageBase
{
    RefCounted!(Functor) actionFunctor;

    this(wxPanel parent, string actionButtonText = "", Functor functor = null)
    {
        super(parent);
        if (actionButtonText.length != 0)
        {
            auto actionButton = new wxButton(this, wxID_ANY, actionButtonText);
            actionFunctor = RefCounted!(Functor)(functor);
            actionButton.connect(wxEVT_COMMAND_BUTTON_CLICKED, &onActionButtonClick);
            InfoPageSizer.add(actionButton, 0, wxALL, 5);
        }
        InfoStaticText.setFocus();
    }

    bool isValid() { return true; }

    void setMaxStaticTextWidth(int width)
    {
        InfoStaticText.wrap(width);
    }

    void setPageText(string text)
    {
        InfoStaticText.setLabel(text);
    }

protected:
    void onActionButtonClick(wxCommandEvent event)
    {
        if (actionFunctor.get !is null)
            actionFunctor.get();
    }
}
