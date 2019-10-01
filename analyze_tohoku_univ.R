# Analyze Tohoku Kibutsu data table
library(tidyverse);library(rvest)
list.files() %>% str_subset('csv')
tohoku_uni <- read_csv('tohoku_uni_tbl.csv')

tohoku_uni %>% View

# remove first col
tohoku_uni <- tohoku_uni %>% select(-none)

# Convert each col to be the appropriate type.
tohoku_uni_r1 <- tohoku_uni %>% 
  mutate(Date = str_replace_all(Date, '年|月|日', '-') %>% as.Date.character, 
         Difficulty = factor(Difficulty, levels = c('ど仏', '仏', 'やや仏', '並', 'やや鬼', '鬼' , 'ど鬼')), 
         Test = factor(Test, levels = c('なし', '時々あり', 'あり')), 
         Report = factor(Report, levels = c('なし', '時々あり', 'あり')), 
         Attendance = factor(Attendance, levels = c('なし', '時々あり', 'あり'))
  ) %>% # View
  # Exclude recodes which seems be wrong or suspicious.
  filter_at(c('Teacher', 'Class'), any_vars(!(. %in% c("", ' ', '　')))) %>% 
  filter_at(c('Test', 'Report', 'Attendance'), any_vars(!is.na(.)))


View(tohoku_uni_r1)  

tohoku_uni_r1 %>% mutate(department = )

# Look over a whole of data

# The difficulty histogram filled by the attendance
tohoku_uni_r1 %>% 
  group_by(Difficulty = fct_explicit_na(Difficulty), Attendance = fct_explicit_na(Attendance)) %>% 
  summarise(count = n()) %>% 
  ggplot()+
  geom_bar(aes(x = Difficulty, y = count, fill = Attendance), stat = 'identity')+
  theme_bw(base_family = "HiraKakuPro-W3")

# Focus on the year.
library(lubridate)
# trace line
tohoku_uni_r1 %>% 
  group_by(Date) %>% 
  summarize(count = n()) %>% 
  ggplot(aes(x = Date, y = count))+
  geom_line()
# cumlative bar plot
tohoku_uni_r1 %>% 
  mutate(year = year(Date), month = month(Date) %>% factor(levels = c(4:12, 1:3))) %>% 
  group_by(year, month = fct_explicit_na(month)) %>% 
  summarize(count = n()) %>% 
  ggplot(aes(x = year, y = count, group = month, fill = month))+
  geom_bar(stat = 'identity')

  
# Slice records which is relevant to pedagogy
tohoku_uni_r1 %>% filter(Class %>% str_detect('教育')) %>% .$Teacher %>% unique

