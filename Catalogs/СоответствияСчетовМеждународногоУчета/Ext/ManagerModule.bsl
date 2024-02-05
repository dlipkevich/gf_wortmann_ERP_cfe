﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

&ИзменениеИКонтроль("СхемыКомпоновкиДанных")
Функция гф_СхемыКомпоновкиДанных(СчетРеглУчета)

	СхемаКомпоновкиДанных = Справочники.СоответствияСчетовМеждународногоУчета.ПолучитьМакет("СхемаКомпоновкиДанных");
	#Вставка
	// ++ Галфинд_ДомнышеваКР_06_12_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee9062a7e31a79
	ДобавитьПоляВСхемуКомпановки(СхемаКомпоновкиДанных);
	// -- Галфинд_ДомнышеваКР_06_12_2023
	#КонецВставки
	ПоляНабора = СхемаКомпоновкиДанных.НаборыДанных[0].Поля;

	ВидыСубконто = ФинансоваяОтчетностьПовтИсп.ВидыСубконтоСчета(СчетРеглУчета);
	Для НомерСубконто = 1 По 3 Цикл
		ПутьКДанным = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("Субконто%1", НомерСубконто);
		Поле = ПоляНабора.Найти(ПутьКДанным);
		СтрокаВидСубконто = ВидыСубконто.Найти(НомерСубконто, "НомерСубконто");
		Если СтрокаВидСубконто <> Неопределено Тогда
			Поле.Заголовок = Строка(СтрокаВидСубконто.ВидСубконто);
			Поле.ТипЗначения = СтрокаВидСубконто.ТипЗначения;
		Иначе
			Поле.ОграничениеИспользования.Условие = Истина;
			Поле.ОграничениеИспользованияРеквизитов.Условие = Истина;
			Поле.ОграничениеИспользования.Поле = Истина;
			Поле.ОграничениеИспользованияРеквизитов.Поле = Истина;
		КонецЕсли;
	КонецЦикла;

	Возврат СхемаКомпоновкиДанных;

КонецФункции  

Процедура ДобавитьПоляВСхемуКомпановки(СхемаКомпоновкиДанных)
	
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee9062a7e31a79
	// Решено использовать поле "Сумма", вместо "ВидДокумента" - оставила для возможного исп-я в будущем
	// Галфинд_Домнышева 2023/12/08
	//Поле = СхемаКомпоновкиДанных.НаборыДанных.ТаблицаДанных.Поля.Добавить(Тип("ПолеНабораДанныхСхемыКомпоновкиДанных"));
	//МассивДокументов = Новый СписокЗначений;
	//Для каждого Документ Из Метаданные.Документы Цикл
	//    МассивДокументов.Добавить(Документ.Имя, Документ.Представление());    
	//КонецЦикла;
	//
	//Поле.Заголовок      =  "Вид Документа";
	//Поле.ПутьКДанным    =  "ВидДокумента";
	//Поле.Поле           =  "ВидДокумента";
	//Поле.ТипЗначения = Новый ОписаниеТипов("Строка");        
	//Поле.УстановитьДоступныеЗначения(МассивДокументов);
	
	Поле = СхемаКомпоновкиДанных.НаборыДанных.ТаблицаДанных.Поля.Добавить(Тип("ПолеНабораДанныхСхемыКомпоновкиДанных"));
	Поле.Заголовок      =  "Сумма";
	Поле.ПутьКДанным    =  "Сумма";
	Поле.Поле           =  "Сумма";
	Поле.ТипЗначения = Новый ОписаниеТипов("Число");
	// } #wortmann
КонецПроцедуры

#КонецОбласти

#КонецЕсли