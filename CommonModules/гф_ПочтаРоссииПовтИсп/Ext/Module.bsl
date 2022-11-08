﻿#Область СлужебныйПрограммныйИнтерфейс

Функция ПолучитьСоответствиеКодовОпераций() Экспорт
	
	СоответствиеКодовОпераций = Новый Соответствие;
	
	ДокументКоды = Обработки.гф_ПочтаРоссииЗапросКТрекеру.ПолучитьМакет("КодыОпераций"); 
	
	КолонкаКодОперации		= 1; 
	КолонкаОперация			= 2; 
	КолонкаКодАтрибута		= 3; 
	КолонкаАтрибут			= 4; 
	КолонкаКонечнаяОперация	= 5; 
	
	КодОперации = Неопределено;
	
	Для НомерСтроки = 2 По ДокументКоды.ВысотаТаблицы Цикл
		
		ОбластьКодОперации		= ДокументКоды.Область(НомерСтроки, КолонкаКодОперации);
		ОбластьОперация			= ДокументКоды.Область(НомерСтроки, КолонкаОперация);
		ОбластьКодАтрибута		= ДокументКоды.Область(НомерСтроки, КолонкаКодАтрибута);
		ОбластьАтрибут			= ДокументКоды.Область(НомерСтроки, КолонкаАтрибут);
		ОбластьКонечнаяОперация	= ДокументКоды.Область(НомерСтроки, КолонкаКонечнаяОперация);
		
		КонечнаяОперация = ЗначениеЗаполнено(ОбластьКонечнаяОперация.Текст);
		
		КодСледующейОперации = гф_ПочтаРоссии.СтрокаВЧисло(ОбластьКодОперации.Текст);
		
		Если ЗначениеЗаполнено(КодСледующейОперации) Тогда       
			
			КодОперации = КодСледующейОперации;
			
			АтрибутыОпераций = Новый Структура;
			
			СоответствиеАтрибутов = Новый Соответствие;
			
			АтрибутыОпераций.Вставить("Имя", ОбластьОперация.Текст);     
			АтрибутыОпераций.Вставить("СоответствиеАтрибутов", СоответствиеАтрибутов);     
			
			СоответствиеКодовОпераций.Вставить(КодОперации, АтрибутыОпераций);
			
		КонецЕсли;	    
		
		КодАтрибута = гф_ПочтаРоссии.СтрокаВЧисло(ОбластьКодАтрибута.Текст);  
		
		АтрибутОперации = Новый Структура;
		
		АтрибутОперации.Вставить("Атрибут", ОбластьАтрибут.Текст);    
		АтрибутОперации.Вставить("КонечнаяОперация", КонечнаяОперация);     
		
		СоответствиеКодовОпераций[КодОперации].СоответствиеАтрибутов.Вставить(КодАтрибута, АтрибутОперации);
		
	КонецЦикла;	
	
	Возврат СоответствиеКодовОпераций; 
	
КонецФункции	

Функция ПолучитьТаблицуСоответствияКодовОпераций() Экспорт
	
	ТаблицаСоответствийКодовОпераций = Новый ТаблицаЗначений;    
	
	КвалификаторыЧисла2		= Новый КвалификаторыЧисла(2, 0, ДопустимыйЗнак.Неотрицательный);
	КвалификаторыСтроки32	= Новый КвалификаторыСтроки(32, ДопустимаяДлина.Переменная);
	КвалификаторыСтроки120	= Новый КвалификаторыСтроки(120, ДопустимаяДлина.Переменная);
	
	ОписаниеТиповБулево		= Новый ОписаниеТипов("Булево");
	ОписаниеТиповЧисло2		= Новый ОписаниеТипов("Число", , , КвалификаторыЧисла2);
	ОписаниеТиповСтрока32	= Новый ОписаниеТипов("Строка", , , КвалификаторыСтроки32);
	ОписаниеТиповСтрока120	= Новый ОписаниеТипов("Строка", , , КвалификаторыСтроки120);
	
	ТаблицаСоответствийКодовОпераций.Колонки.Добавить("КодОперации",		ОписаниеТиповЧисло2);
	ТаблицаСоответствийКодовОпераций.Колонки.Добавить("КодАтрибута",		ОписаниеТиповЧисло2);
	ТаблицаСоответствийКодовОпераций.Колонки.Добавить("Операция",			ОписаниеТиповСтрока32);
	ТаблицаСоответствийКодовОпераций.Колонки.Добавить("Атрибут",			ОписаниеТиповСтрока120);
	ТаблицаСоответствийКодовОпераций.Колонки.Добавить("КонечнаяОперация",	ОписаниеТиповБулево);
	
	ДокументКоды = Обработки.гф_ПочтаРоссииЗапросКТрекеру.ПолучитьМакет("КодыОпераций"); 
	
	КолонкаКодОперации		= 1; 
	КолонкаОперация			= 2; 
	КолонкаКодАтрибута		= 3; 
	КолонкаАтрибут			= 4; 
	КолонкаКонечнаяОперация	= 5; 
	
	КодОперации = Неопределено;
	
	Для НомерСтроки = 2 По ДокументКоды.ВысотаТаблицы Цикл
		
		ОбластьКодОперации		= ДокументКоды.Область(НомерСтроки, КолонкаКодОперации);
		ОбластьОперация			= ДокументКоды.Область(НомерСтроки, КолонкаОперация);
		ОбластьКодАтрибута		= ДокументКоды.Область(НомерСтроки, КолонкаКодАтрибута);
		ОбластьАтрибут			= ДокументКоды.Область(НомерСтроки, КолонкаАтрибут);
		ОбластьКонечнаяОперация	= ДокументКоды.Область(НомерСтроки, КолонкаКонечнаяОперация);
		
		КодСледующейОперации = гф_ПочтаРоссии.СтрокаВЧисло(ОбластьКодОперации.Текст);
		
		Если ЗначениеЗаполнено(КодСледующейОперации) Тогда       
			
			КодОперации	= КодСледующейОперации; 
			Операция	= ОбластьОперация.Текст;
			
		КонецЕсли;	 
		
		СтрокаСоответствия = ТаблицаСоответствийКодовОпераций.Добавить();
		
		СтрокаСоответствия.КодОперации		= КодОперации;
		СтрокаСоответствия.КодАтрибута		= гф_ПочтаРоссии.СтрокаВЧисло(ОбластьКодАтрибута.Текст);
		СтрокаСоответствия.Операция			= Операция;
		СтрокаСоответствия.Атрибут			= ?(СтрокаСоответствия.КодАтрибута = 0, "", ОбластьАтрибут.Текст);
		СтрокаСоответствия.КонечнаяОперация	= ЗначениеЗаполнено(ОбластьКонечнаяОперация.Текст);
		
	КонецЦикла;	
	
	Возврат ТаблицаСоответствийКодовОпераций; 
	
КонецФункции	

#КонецОбласти


