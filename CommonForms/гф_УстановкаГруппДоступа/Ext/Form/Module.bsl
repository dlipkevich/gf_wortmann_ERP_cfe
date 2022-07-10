﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("ГруппаДоступаПартнера",ГруппаДоступаПартнера) Тогда
	
		КомандаОбновитьНаСервере();
		
	Иначе
		
		Элементы.ГруппаДоступаКонтрагента.Вид = ВидПоляФормы.ПолеВвода;
		
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ГруппаДоступаКонтрагентаПриИзменении(Элемент)
	
	КомандаОбновитьНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыОрганизациииГруппы

&НаКлиенте
Процедура ТаблицаОрганизацийГруппГруппаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДанныеВыбора = Новый СписокЗначений;
	
	ТекущиеДанные = Элементы.ТаблицаОрганизацийГрупп.ТекущиеДанные;
	
	Отбор = Новый Структура("Организация",ТекущиеДанные.Организация);
	
	СтрокиГруппОрганизации = ТаблицаОрганизацийГруппДляВыбора.НайтиСтроки(Отбор);
	
	Для Каждого СтрокаГруппы Из СтрокиГруппОрганизации Цикл
		
		ДанныеВыбора.Добавить(СтрокаГруппы.Группа);
		
	КонецЦикла;	
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаОбновить(Команда)
	
	КомандаОбновитьНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура КомандаЗаписатьНаСервере()
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ГруппыДоступа.Ссылка КАК ГруппаДоступа
	|ПОМЕСТИТЬ ВТ_Есть
	|ИЗ
	|	Константы КАК Константы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ГруппыДоступа КАК Организации
	|		ПО Константы.гф_ГруппыДоступаДляКонтрагентов = Организации.Родитель
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ГруппыДоступа КАК ГруппыДоступа
	|		ПО (Организации.Ссылка = ГруппыДоступа.Родитель)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ГруппыДоступа.ЗначенияДоступа КАК ГруппыДоступаЗначенияДоступа
	|		ПО (ГруппыДоступа.Ссылка = ГруппыДоступаЗначенияДоступа.Ссылка)
	|			И (ГруппыДоступаЗначенияДоступа.ЗначениеДоступа = &ГруппаДоступаПартнеров)
	|ГДЕ
	|	Организации.ЭтоГруппа   
	|	
	|;
	|
	|ВЫБРАТЬ
	|	ВТ_Есть.ГруппаДоступа КАК ГруппаДоступа,
	|	ЛОЖЬ КАК СоздатьУдалить
	|ИЗ
	|	ВТ_Есть КАК ВТ_Есть
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Нужно КАК ВТ_Нужно
	|		ПО ВТ_Есть.ГруппаДоступа = ВТ_Нужно.ГруппаДоступа
	|ГДЕ
	|	ВТ_Нужно.ГруппаДоступа ЕСТЬ NULL
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ВТ_Нужно.ГруппаДоступа КАК ГруппаДоступа,
	|	ИСТИНА КАК СоздатьУдалить
	|ИЗ
	|	ВТ_Нужно КАК ВТ_Нужно
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Есть КАК ВТ_Есть
	|		ПО (ВТ_Нужно.ГруппаДоступа = ВТ_Есть.ГруппаДоступа)
	|ГДЕ
	|	ВТ_Есть.ГруппаДоступа ЕСТЬ NULL";
	
	Запрос.Параметры.Вставить("ГруппаДоступаПартнеров",ГруппаДоступаПартнера);
	Запрос.Параметры.Вставить("ТаблицаГрупп",ТаблицаОрганизацийГрупп.Выгрузить());
	
	Результат = Запрос.Выполнить();   
	
	Если Не Результат.Пустой() Тогда
		
		Выборка = Результат.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			
			ГруппаОбъект = Выборка.ГруппаДоступа.ПолучитьОбъект();
			
			Если Выборка.СоздатьУдалить Тогда
				
				СтрокаЗначенияДоступа = ГруппаОбъект.ЗначенияДоступа.Добавить();						
				
				СтрокаЗначенияДоступа.ЗначениеДоступа = ГруппаДоступаПартнера;
				
			Иначе
				
				СтрокаЗначенияДоступа = ГруппаОбъект.ЗначенияДоступа.Найти(ГруппаДоступаПартнера,"ЗначениеДоступа");
				
				Если СтрокаЗначенияДоступа <> Неопределено Тогда
					
					ГруппаОбъект.ЗначенияДоступа.Удалить(ГруппаОбъект.ЗначенияДоступа.Индекс(СтрокаЗначенияДоступа));	
					
				КонецЕсли;	
				
			КонецЕсли;	
			
			ГруппаОбъект.Записать();
			
		КонецЦикла;	
		
	КонецЕсли;	 
	
	КомандаОбновитьНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаЗаписать(Команда)
	
	КомандаЗаписатьНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаЗаписатьЗакрыть(Команда) 
	
	КомандаЗаписатьНаСервере();
	
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура КомандаОбновитьНаСервере()
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	|	Организации.Ссылка КАК Организация,
	|	ГруппыДоступа.Ссылка КАК ГруппаДоступа,
	|	Организации.Наименование КАК ОрганизацияНаименование,
	|	ГруппыДоступа.Наименование КАК ГруппаДоступаНаименование
	|ПОМЕСТИТЬ ВТ_ОрганизацииГруппыДоступа
	|ИЗ
	|	Константы КАК Константы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ГруппыДоступа КАК Организации
	|		ПО Константы.гф_ГруппыДоступаДляКонтрагентов = Организации.Родитель
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ГруппыДоступа КАК ГруппыДоступа
	|		ПО (Организации.Ссылка = ГруппыДоступа.Родитель)
	|ГДЕ
	|	Организации.ЭтоГруппа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВТ_ОрганизацииГруппыДоступа.Организация КАК Организация
	|ИЗ
	|	ВТ_ОрганизацииГруппыДоступа КАК ВТ_ОрганизацииГруппыДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВТ_ОрганизацииГруппыДоступа.Организация КАК Организация,
	|	ВТ_ОрганизацииГруппыДоступа.ГруппаДоступа КАК Группа
	|ИЗ
	|	ВТ_ОрганизацииГруппыДоступа КАК ВТ_ОрганизацииГруппыДоступа
	|ГДЕ
	|	НЕ ВТ_ОрганизацииГруппыДоступа.ГруппаДоступа ЕСТЬ NULL
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ОрганизацииГруппыДоступа.Организация КАК Организация,
	|	ВТ_ОрганизацииГруппыДоступа.ГруппаДоступа КАК Группа
	|ИЗ
	|	Справочник.ГруппыДоступа.ЗначенияДоступа КАК ГруппыДоступаЗначенияДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ОрганизацииГруппыДоступа КАК ВТ_ОрганизацииГруппыДоступа
	|		ПО ГруппыДоступаЗначенияДоступа.Ссылка = ВТ_ОрганизацииГруппыДоступа.ГруппаДоступа
	|			И (ГруппыДоступаЗначенияДоступа.ЗначениеДоступа = &ГруппаДоступаПартнеров)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВТ_ОрганизацииГруппыДоступа.ОрганизацияНаименование,
	|	ВТ_ОрганизацииГруппыДоступа.ГруппаДоступаНаименование";
	
	Запрос.Параметры.Вставить("ГруппаДоступаПартнеров",ГруппаДоступаПартнера);
	
	Результат = Запрос.ВыполнитьПакет(); 
	
	ИндексРезультатаОрганизацийГрупп	= Результат.Количество()-1;
	ИндексРезультатаГруппДляВыбора		= Результат.Количество()-2;
	ИндексРезультатаОрганизаций			= Результат.Количество()-3;
	
	ТаблицаОрганизацийГрупп.Загрузить(Результат[ИндексРезультатаОрганизацийГрупп].Выгрузить());
	
	Элементы.ТаблицаОрганизацийГруппОрганизация.СписокВыбора.Очистить();
	
	ВыборкаОрганизаций = Результат[ИндексРезультатаОрганизаций].Выбрать();
	
	Пока ВыборкаОрганизаций.Следующий() Цикл
		
		Элементы.ТаблицаОрганизацийГруппОрганизация.СписокВыбора.Добавить(ВыборкаОрганизаций.Организация);
		
	КонецЦикла;	   
	
	ТаблицаОрганизацийГруппДляВыбора.Загрузить(Результат[ИндексРезультатаГруппДляВыбора].Выгрузить());
	
КонецПроцедуры

#КонецОбласти
