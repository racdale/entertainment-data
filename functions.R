get_word_tokens = function(txt) {
  txt = tolower(txt)
  txt = gsub(',','',txt)
  txt = gsub('\\.','',txt)
  return(unlist(strsplit(txt,' ')))
}
