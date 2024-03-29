﻿#Область ОбработчикиСобытийФормы

// #wortmann {
// устанавливает значения реквизитов из переданных парметров
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8121bcee7bda45d711ed43f091be2e6a
// Галфинд_Домнышева 2022/10/06
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Реализация = Параметры["Реализация"];
	Организация = Параметры["Организация"];
    Партнер = Параметры["Партнер"];
	
	ПрочитатьДанные();
	 
КонецПроцедуры// } #wortmann

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписокУЛ

// #wortmann {
// устанавливает отбор в ТЧ СписокУЛ по значению ДокументРТУ из ТЧ ДокументыРТУ 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8121bcee7bda45d711ed43f091be2e6a
// Галфинд_Домнышева 2022/10/06
&НаКлиенте
Процедура ДокументыРТУПриАктивизацииСтроки(Элемент)
	
	ТекущиеДанные = Элементы.ДокументыРТУ.ТекущиеДанные;	
	Если ТекущиеДанные <> Неопределено Тогда
		ДокументРТУ = ТекущиеДанные.ДокументРТУ;
	Иначе
		ДокументРТУ = ПредопределенноеЗначение("Документ.РеализацияТоваровУслуг.ПустаяСсылка");
	КонецЕсли;
	   
	ОтборПоДокументу = Новый ФиксированнаяСтруктура("ДокументРТУ", ДокументРТУ);
	
	Элементы.СписокУЛ.ОтборСтрок = ОтборПоДокументу;

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

// #wortmann {
// устанавливает флаг Истина у всех строк если команда "ОтметитьВсе", иначе снимает флаг со всех строк. 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8121bcee7bda45d711ed43f091be2e6a
// Галфинд_Домнышева 2022/10/06 
&НаКлиенте
Процедура Отметить(Команда)
	Флаг = (Команда = Команды["ОтметитьВсе"]);
	
	Для Каждого СтрокаУпаковочныхЛистов Из СписокУЛ Цикл
		
		СтрокаУпаковочныхЛистов.Флаг = Флаг;
		
	КонецЦикла;
КонецПроцедуры

// #wortmann {
// формирование массива строк для передачи в формуДокумента в процедуру ПодборЗавершение 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8121bcee7bda45d711ed43f091be2e6a
// Галфинд_Домнышева 2022/10/06
&НаКлиенте
Процедура ЗавершитьПодбор(Команда)
	
	МассивВыделенных = СписокУЛ.НайтиСтроки(Новый Структура("Флаг",Истина));
		
	МассивВыбранных = Новый Массив; 

	Для каждого ИденСтроки Из МассивВыделенных Цикл
		
		СтруСтроки = Новый Структура("УпаковочныйЛист, Артикул, IDКороба, КоличествоПар");
		
		ЗаполнитьЗначенияСвойств(СтруСтроки, ИденСтроки);
		
		МассивВыбранных.Добавить(СтруСтроки);
		
	КонецЦикла;

	Закрыть(МассивВыбранных);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// #wortmann {
// Заполняет ТЧ ДокументыРТУ и СписокУЛ 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8121bcee7bda45d711ed43f091be2e6a
// Галфинд_Домнышева 2022/10/06
&НаСервере
Процедура ПрочитатьДанные()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	РеализацияТоваровУслуггф_ТоварыВКоробах.Ссылка КАК Ссылка
		|ПОМЕСТИТЬ РТУ
		|ИЗ
		|	Документ.РеализацияТоваровУслуг.гф_ТоварыВКоробах КАК РеализацияТоваровУслуггф_ТоварыВКоробах
		|ГДЕ
		|	РеализацияТоваровУслуггф_ТоварыВКоробах.НомерСтроки = 1
		|	И РеализацияТоваровУслуггф_ТоварыВКоробах.Ссылка.Организация = &Организация
		|	И РеализацияТоваровУслуггф_ТоварыВКоробах.Ссылка.Партнер = &Партнер
		|	И РеализацияТоваровУслуггф_ТоварыВКоробах.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	РеализацияТоваровУслуггф_ТоварыВКоробах.УпаковочныйЛист КАК УпаковочныйЛист,
		|	РеализацияТоваровУслуггф_ТоварыВКоробах.Артикул КАК Артикул,
		|	РеализацияТоваровУслуггф_ТоварыВКоробах.КоличествоПар КАК КоличествоПар,
		|	РеализацияТоваровУслуггф_ТоварыВКоробах.УпаковочныйЛист.Код КАК IDКороба,
		|	РеализацияТоваровУслуггф_ТоварыВКоробах.Ссылка КАК ДокументРТУ
		|ИЗ
		|	Документ.РеализацияТоваровУслуг.гф_ТоварыВКоробах КАК РеализацияТоваровУслуггф_ТоварыВКоробах,
		|	РТУ КАК РТУ
		|ГДЕ
		|	РеализацияТоваровУслуггф_ТоварыВКоробах.Ссылка = РТУ.Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	РТУ.Ссылка КАК ДокументРТУ,
		|	РТУ.Ссылка.Номер КАК Номер,
		|	РТУ.Ссылка.Дата КАК Дата
		|ИЗ
		|	РТУ КАК РТУ";
	
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Партнер", Партнер);
	Запрос.УстановитьПараметр("Ссылка", Реализация);
	Если Реализация = Документы.РеализацияТоваровУслуг.ПустаяСсылка() Тогда		
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "И РеализацияТоваровУслуггф_ТоварыВКоробах.Ссылка = &Ссылка", "");
	КонецЕсли;
		
	ДокументыРТУ.Очистить();
	СписокУЛ.Очистить();
	
	Результат = Запрос.ВыполнитьПакет(); 
	
	ИндексДокументыРТУ	= Результат.Количество() - 1;
	ИндексСписокУЛ			= Результат.Количество() - 2;
	
	ДокументыРТУ.Загрузить(Результат[ИндексДокументыРТУ].Выгрузить());
	СписокУЛ.Загрузить(Результат[ИндексСписокУЛ].Выгрузить());
	
КонецПроцедуры

#КонецОбласти