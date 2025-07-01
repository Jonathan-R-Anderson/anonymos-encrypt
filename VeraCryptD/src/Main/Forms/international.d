module Main.Forms.international;

version(TC_WINDOWS) {}
else {
    import Main.LanguageStrings;
    string _(string key) { return LangString[key]; }
}
