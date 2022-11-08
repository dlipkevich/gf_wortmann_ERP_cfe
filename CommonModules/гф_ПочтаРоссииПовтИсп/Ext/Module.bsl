﻿#Область СлужебныйПрограммныйИнтерфейс

// Возвращает таблицу кодов и атрибутов операций
// из табличного документа Обработки.гф_ПочтаРоссииЗапросКТрекеру.КодыОпераций
Функция ПолучитьТаблицуСоответствияКодовОпераций() Экспорт
	
	ТаблицаСоответствийКодовОпераций = Новый ТаблицаЗначений;    
	
	КвалификаторыЧисла4		= Новый КвалификаторыЧисла(4, 0, ДопустимыйЗнак.Неотрицательный);
	КвалификаторыСтроки64	= Новый КвалификаторыСтроки(64, ДопустимаяДлина.Переменная);
	КвалификаторыСтроки120	= Новый КвалификаторыСтроки(120, ДопустимаяДлина.Переменная);
	
	ОписаниеТиповБулево		= Новый ОписаниеТипов("Булево");
	ОписаниеТиповЧисло4		= Новый ОписаниеТипов("Число", , , КвалификаторыЧисла4);
	ОписаниеТиповСтрока64	= Новый ОписаниеТипов("Строка", , , КвалификаторыСтроки64);
	ОписаниеТиповСтрока120	= Новый ОписаниеТипов("Строка", , , КвалификаторыСтроки120);
	
	ТаблицаСоответствийКодовОпераций.Колонки.Добавить("КодОперации",		ОписаниеТиповЧисло4);
	ТаблицаСоответствийКодовОпераций.Колонки.Добавить("КодАтрибута",		ОписаниеТиповЧисло4);
	ТаблицаСоответствийКодовОпераций.Колонки.Добавить("Операция",			ОписаниеТиповСтрока64);
	ТаблицаСоответствийКодовОпераций.Колонки.Добавить("Атрибут",			ОписаниеТиповСтрока120);
	ТаблицаСоответствийКодовОпераций.Колонки.Добавить("КонечнаяОперация",	ОписаниеТиповБулево);
	
	ДокументКоды = Обработки.гф_ПочтаРоссииЗапросКТрекеру.ПолучитьМакет("КодыОпераций"); 
	
	КолонкаКодОперации		= 1; 
	КолонкаОперация			= 2; 
	КолонкаКодАтрибута		= 3; 
	КолонкаАтрибут			= 4; 
	КолонкаКонечнаяОперация	= 5;  
	
	ПерваяСтрокаДанных		= 2;
	
	КодОперации = Неопределено;
	
	Для НомерСтроки = ПерваяСтрокаДанных По ДокументКоды.ВысотаТаблицы Цикл
		
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

// Возвращает соответствие кодов и атрибутов операций
// из табличного документа Обработки.гф_ПочтаРоссииЗапросКТрекеру.КодыОпераций
// аналогично ПолучитьТаблицуСоответствияКодовОпераций, но сериализуемое
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

#КонецОбласти


