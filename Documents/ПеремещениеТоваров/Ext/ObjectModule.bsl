﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

&Перед("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ДокументОснование) И ТипЗнч(ДокументОснование) = Тип("ДокументСсылка.РасходныйОрдерНаТовары") Тогда 
		
		// При ручном и автоматическом проведении и перепроведении не перезаполняем табличную часть "гф_ШтрихкодыУпаковок".
		// В процедуре ниже "гф_ЗаполнитьШтрихкодыУпаковок()", алгоритм формирует записи не подходящие записи в табличную часть
		// для формирования УПД.
		гф_СкладскаяОперация = ОбщегоНазначенияУТВызовСервера.ЗначениеРеквизитаОбъекта(ЭтотОбъект.ДокументОснование, "СкладскаяОперация");
		
		Если гф_СкладскаяОперация = Перечисления.СкладскиеОперации.ОтгрузкаПоПеремещению Тогда
			Возврат;	
		КонецЕсли;
		
	КонецЕсли;
	
	// vvv Галфинд \ Sakovich 22.10.2022
	// иначе не изменить даже с помошью СДР
	Если Не ОбменДанными.Загрузка Тогда
	// ^^^ Галфинд \ Sakovich 22.10.2022 
		
		// #wortmann {
		// #5.2.08
		// ID запрет ручного изменения документа, при наличии свойства "гф_ДокументОснование"
		// Галфинд Volkov 2022/08/23
		Если Не ЭтотОбъект.ДополнительныеСвойства.Свойство("гф_ДокументОснование") 
			И ЗначениеЗаполнено(ЭтотОбъект.ДокументОснование) Тогда
			//Отказ = Истина;
			//СтрокаСообщения = НСтр("ru = 'Данный документ не доступен для ручного изменения. Введен на основании %1.'");
			//ТекстСообщения = СтрШаблон(СтрокаСообщения, ЭтотОбъект.ДокументОснование);
			//ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, ЭтотОбъект.ДокументОснование, , , Отказ);
		КонецЕсли;
		// } #wortmann
		
	// vvv Галфинд \ Sakovich 22.10.2022	
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 22.10.2022 
	
	// #wortmann {
	// При проведении необходимо перезаполнять тч "гф_ШтрихкодыУпаковок"
	// Галфинд Sakovich 2022/10/22
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		гф_ЗаполнитьШтрихкодыУпаковок();
	КонецЕсли;
	// } #wortmann
		
КонецПроцедуры

&После("ОбработкаПроверкиЗаполнения")
Процедура гф_ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	// #wortmann {
	// если склад-отправитель коробной, то тч. ТоварыВКоробах должна быть заполнена
	// Галфинд Sakovich 2022/10/26
	ЭтоКоробочныйСклад = УправлениеСвойствами.ЗначениеСвойства(СкладОтправитель, "гф_СкладыТоварыВКоробах") = Истина;
	Если ЭтоКоробочныйСклад Тогда
		Если гф_ТоварыВКоробах.Количество() = 0 Тогда
			СтрокаСообщения = НСтр("ru = 'Не заполнена табличная часть ""Товары в коробах""!.'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СтрокаСообщения, ЭтотОбъект, "гф_ТоварыВКоробах", , Отказ);
		КонецЕсли;
	КонецЕсли;
	// } #wortmann
КонецПроцедуры

&После("ОбработкаПроведения")
Процедура гф_ОбработкаПроведения(Отказ, РежимПроведения)
	
	// ОтгрузкаПеремещением
	// Обговорена проверка на заполнение рекв.гф_ЗаказКлиента 
	// ++ Галфинд_Домнышева_19_04-2023
	Если НЕ ЗначениеЗаполнено(ЭтотОбъект.гф_ЗаказКлиента) Тогда
		Возврат;
	КонецЕсли;
    // -- Галфинд_Домнышева_19_04-2023

	// РН ЗаказыКлиентов
	ДокументСсылка = ЭтотОбъект.Ссылка;
	Документ = ДокументСсылка.ПолучитьОбъект();
	
	НаборЗаписей = Документ.Движения.ЗаказыКлиентов;
	НаборЗаписей.Прочитать();
	
	Для Каждого Запись Из НаборЗаписей Цикл
		Запись.КодСтроки = 0;
		Запись.Склад = Документ.СкладОтправитель;
	КонецЦикла;
	
	НаборЗаписей.Записать(Истина);
	
	// РН ЗапасыИПотребности
	НаборЗаписей = Документ.Движения.ЗапасыИПотребности;
	НаборЗаписей.Прочитать();
	
	Для Каждого Запись Из НаборЗаписей Цикл
		Запись.ОтгружаемыйЗаказ = ДокументСсылка.гф_ЗаказКлиента;
	КонецЦикла;
	
	НаборЗаписей.Записать(Истина);
	
	// РН ТоварыКОтгрузке
	ДокументСсылка = ЭтотОбъект.Ссылка;
	Документ = ДокументСсылка.ПолучитьОбъект();
	
	НаборЗаписей = Документ.Движения.ТоварыКОтгрузке;
	НаборЗаписей.Прочитать();
	
	МассивЗаписейНаУдаление = Новый Массив;
	
	Для Каждого Запись Из НаборЗаписей Цикл
		
		Если Запись.ВидДвижения = ВидДвиженияНакопления.Приход Тогда
			Запись.ВидДвижения = ВидДвиженияНакопления.Расход;
		ИначеЕсли Запись.ВидДвижения = ВидДвиженияНакопления.Расход Тогда
			МассивЗаписейНаУдаление.Добавить(Запись);
		КонецЕсли;
			
	КонецЦикла;
	
	НаборЗаписей.Удалить(Запись);
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ОпределитьКоробнойПарный(Склад)
	СкладВКоробах = УправлениеСвойствами.ЗначениеСвойства(Склад, "гф_СкладыТоварыВКоробах") = Истина;
	Возврат СкладВКоробах;
КонецФункции 

Функция ОпределитьОрдерныйЛиСклад(Склад) Экспорт

	ДатаПроверкиОрдернойСхемы = ?(ЭтоНовый(), ТекущаяДатаСеанса(), Дата);
	СкладОрдерный = СкладыСервер.ИспользоватьОрдернуюСхемуПриОтгрузке(
		Склад,
		ДатаПроверкиОрдернойСхемы);
	Возврат СкладОрдерный;

КонецФункции

Функция ПроверитьНаличиеОрдераПоОснованию(ВидОрдера) Экспорт
	
	
	Если ВидОрдера = "РасходныйОрдерНаТовары" Тогда
		ТекстЗапроса = "ВЫБРАТЬ
		|	ОрдерНаТовары.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.РасходныйОрдерНаТовары.ТоварыПоРаспоряжениям КАК ОрдерНаТовары
		|ГДЕ
		|	ОрдерНаТовары.Распоряжение = &Основание
		|	И НЕ ОрдерНаТовары.Ссылка.ПометкаУдаления";
		
	ИначеЕсли ВидОрдера = "ПриходныйОрдерНаТовары" Тогда	
		ТекстЗапроса = "ВЫБРАТЬ
		|	ОрдерНаТовары.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.ПриходныйОрдерНаТовары КАК ОрдерНаТовары
		|ГДЕ
		|	ОрдерНаТовары.Распоряжение = &Основание
		|	И НЕ ОрдерНаТовары.ПометкаУдаления";
		
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Основание", Ссылка);
	Результат = Запрос.Выполнить();
	Возврат Не Результат.Пустой();
	
КонецФункции 

Процедура гф_ЗаполнитьШтрихкодыУпаковок() 
	
	Если ЭтотОбъект.ДополнительныеСвойства.Свойство("гф_ОтгрузкаПеремещением") Тогда 
		Возврат;
	КонецЕсли;  
	
	// ++ Галфинд_Домнышева_15_01_2024
	Если ДокументСозданЧерезВводОстатков() Тогда
		 Возврат;
	КонецЕсли;
	// -- Галфинд_Домнышева_15_01_2024

	Если Не (Статус = Перечисления.СтатусыПеремещенийТоваров.Принято 
		Или Статус = Перечисления.СтатусыПеремещенийТоваров.Отгружено) Тогда
		Возврат;
	КонецЕсли;
	
	СкладОтправительОрдерный = ОпределитьОрдерныйЛиСклад(СкладОтправитель);
	СкладПолучательОрдерный = ОпределитьОрдерныйЛиСклад(СкладПолучатель);
	
	СкладОтправительВКоробах = ОпределитьКоробнойПарный(СкладОтправитель);
	СкладПолучательВКоробах = ОпределитьКоробнойПарный(СкладПолучатель);
	
	Если СкладОтправительОрдерный Тогда // 1. с_Ордерного_на_Ордерный  // 2. с_Ордерного_на_Виртуальный
		ИсточникШК =  "РасходныйОрдер";
	ИначеЕсли СкладПолучательОрдерный Тогда // 3. с_Виртуального_на_Ордерный
		ИсточникШК =  "ПриходныйОрдер";
	Иначе
		Возврат;
	КонецЕсли;
	
	Если СкладОтправительВКоробах И СкладПолучательВКоробах Тогда   // 1а коробной_коробной
		ВидЗаполнения =  "Агрегаты";
	ИначеЕсли СкладОтправительВКоробах И Не СкладПолучательВКоробах Тогда  // 1б коробной_парный
		ВидЗаполнения =  "КМ"; 
	ИначеЕсли Не (СкладОтправительВКоробах Или СкладПолучательВКоробах) Тогда    // 1в парный_парный
		ВидЗаполнения =  "Штрихкоды"; 
	Иначе
		Возврат;
	КонецЕсли;
	
	гф_ШтрихкодыУпаковок.Очистить();
	
	ЗаполнитьШтрихкоды(ИсточникШК, ВидЗаполнения);
	
КонецПроцедуры

// Заполняет табличную часть "гф_ШтрихкодыУпаковок"
//
// Параметры:
//  Источник - Строка - "РасходныйОрдер", "ПриходныйОрдер"
//  ВидВыборки - строка - "Агрегаты", "КМ", "Штрихкоды"
Процедура ЗаполнитьШтрихкоды(Источник, ВидВыборки)
	
	ТекстЗапроса = "";
	
	Если Источник  = "ПриходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ
		|	ПриходныйОрдерНаТовары.Ссылка КАК Ордер
		|ПОМЕСТИТЬ Ордера
		|ИЗ
		|	Документ.ПриходныйОрдерНаТовары КАК ПриходныйОрдерНаТовары
		|ГДЕ
		|	ПриходныйОрдерНаТовары.Проведен
		|	И ПриходныйОрдерНаТовары.Распоряжение = &Распоряжение";
	КонецЕсли;
	Если Источник = "РасходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	РасходныйОрдерНаТоварыТоварыПоРаспоряжениям.Ссылка КАК Ордер
		|ПОМЕСТИТЬ Ордера
		|ИЗ
		|	Документ.РасходныйОрдерНаТовары.ТоварыПоРаспоряжениям КАК РасходныйОрдерНаТоварыТоварыПоРаспоряжениям
		|ГДЕ
		|	РасходныйОрдерНаТоварыТоварыПоРаспоряжениям.Ссылка.Проведен
		|	И РасходныйОрдерНаТоварыТоварыПоРаспоряжениям.Распоряжение = &Распоряжение";
	КонецЕсли;
	
	ТекстЗапроса = ТекстЗапроса + ОбщегоНазначения.РазделительПакетаЗапросов();
	
	Если ВидВыборки = "Агрегаты" И Источник = "РасходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	РасходныйОрдерНаТоварыОтгружаемыеТовары.УпаковочныйЛист.гф_Агрегация КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.РасходныйОрдерНаТовары.ОтгружаемыеТовары КАК РасходныйОрдерНаТоварыОтгружаемыеТовары
		|		ПО Ордера.Ордер = РасходныйОрдерНаТоварыОтгружаемыеТовары.Ссылка
		|ГДЕ
		|	РасходныйОрдерНаТоварыОтгружаемыеТовары.УпаковочныйЛист.гф_Агрегация ЕСТЬ НЕ NULL 
		|	И НЕ РасходныйОрдерНаТоварыОтгружаемыеТовары.УпаковочныйЛист.гф_Агрегация = ЗНАЧЕНИЕ(Справочник.ШтрихкодыУпаковокТоваров.ПустаяСсылка)";
	КонецЕсли;
	Если ВидВыборки = "Агрегаты" И Источник = "ПриходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПриходныйОрдерНаТоварыТовары.УпаковочныйЛист.гф_Агрегация КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ПриходныйОрдерНаТовары.Товары КАК ПриходныйОрдерНаТоварыТовары
		|		ПО Ордера.Ордер = ПриходныйОрдерНаТоварыТовары.Ссылка
		|ГДЕ
		|	ПриходныйОрдерНаТоварыТовары.УпаковочныйЛист.гф_Агрегация ЕСТЬ НЕ NULL 
		|	И НЕ ПриходныйОрдерНаТоварыТовары.УпаковочныйЛист.гф_Агрегация = ЗНАЧЕНИЕ(Справочник.ШтрихкодыУпаковокТоваров.ПустаяСсылка)";
		
	КонецЕсли;
	Если ВидВыборки = "КМ" И Источник = "РасходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.РасходныйОрдерНаТовары.ОтгружаемыеТовары КАК РасходныйОрдерНаТоварыОтгружаемыеТовары
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ШтрихкодыУпаковокТоваровВложенныеШтрихкоды
		|			ПО РасходныйОрдерНаТоварыОтгружаемыеТовары.УпаковочныйЛист.гф_Агрегация = ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Ссылка
		|		ПО Ордера.Ордер = РасходныйОрдерНаТоварыОтгружаемыеТовары.Ссылка";
	КонецЕсли;
	Если ВидВыборки = "КМ" И Источник = "ПриходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ПриходныйОрдерНаТовары.Товары КАК ПриходныйОрдерНаТоварыТовары
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ШтрихкодыУпаковокТоваровВложенныеШтрихкоды
		|			ПО ПриходныйОрдерНаТоварыТовары.УпаковочныйЛист.гф_Агрегация = ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Ссылка
		|		ПО Ордера.Ордер = ПриходныйОрдерНаТоварыТовары.Ссылка";
	КонецЕсли;
	Если ВидВыборки = "Штрихкоды" И Источник = "РасходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	РасходныйОрдерНаТоварыШтрихкодыУпаковок.ШтрихкодУпаковки КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.РасходныйОрдерНаТовары.ШтрихкодыУпаковок КАК РасходныйОрдерНаТоварыШтрихкодыУпаковок
		|		ПО Ордера.Ордер = РасходныйОрдерНаТоварыШтрихкодыУпаковок.Ссылка";
	КонецЕсли;
	Если ВидВыборки = "Штрихкоды" И Источник = "ПриходныйОрдер" Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПриходныйОрдерНаТоварыШтрихкодыУпаковок.ШтрихкодУпаковки КАК ШтрихкодУпаковки
		|ИЗ
		|	Ордера КАК Ордера
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ПриходныйОрдерНаТовары.ШтрихкодыУпаковок КАК ПриходныйОрдерНаТоварыШтрихкодыУпаковок
		|		ПО Ордера.Ордер = ПриходныйОрдерНаТоварыШтрихкодыУпаковок.Ссылка";
	КонецЕсли;
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Распоряжение", Ссылка);
	Результат = Запрос.Выполнить();
	
	гф_ШтрихкодыУпаковок.Загрузить(Результат.Выгрузить());
	
КонецПроцедуры

// #wortmann {
// Процедура перенеса из Формы Документа 
// Галфинд_Домнышева 2023/04/24	 
Процедура гф_ПроверитьСоздатьОрдераПоПеремещению(обПеремещение, ПараметрыЗаписи) Экспорт
	
	Если Не ПараметрыЗаписи["РежимЗаписи"] = РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	НужноСоздаватьРасходныйОрдер = Ложь;
	НужноСоздаватьПриходныйОрдер = Ложь;
	
	лСкладОтправитель = СкладОтправитель;
	лСкладПолучатель = СкладПолучатель; 	
	
	СкладОтправительОрдерный = ОпределитьОрдерныйЛиСклад(лСкладОтправитель);
	СкладПолучательОрдерный  = ОпределитьОрдерныйЛиСклад(лСкладПолучатель);
	СкладПолучательКоробочный = УправлениеСвойствами.ЗначениеСвойства(лСкладПолучатель, "гф_СкладыТоварыВКоробах") = Истина;
	СкладОтправительКоробочный = УправлениеСвойствами.ЗначениеСвойства(лСкладОтправитель, "гф_СкладыТоварыВКоробах") = Истина;
	
	ЗапросТекст = "ВЫБРАТЬ
	|	регТКП.Номенклатура КАК Номенклатура,
	|	регТКП.Характеристика КАК Характеристика,
	|	регТКП.Назначение КАК Назначение,
	|	регТКП.Склад КАК Склад,
	|	регТКП.Отправитель КАК Отправитель,
	|	регТКП.ХозяйственнаяОперация КАК ХозяйственнаяОперация,
	|	регТКП.КОформлениюПоступленийПоРаспоряжениюПриход КАК КоличествоРОТ,
	|	регТКП.КОформлениюПоступленийПоРаспоряжениюРасход КАК КоличествоПОТ,
	|	ВЫБОР
	|		КОГДА регТКП.КОформлениюПоступленийПоРаспоряжениюПриход <> 0
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК РОТ,
	|	ВЫБОР
	|		КОГДА регТКП.КОформлениюПоступленийПоРаспоряжениюРасход <> 0
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ПОТ,
	|	ШтрихкодыНоменклатуры.Штрихкод КАК Штрихкод,
	|	регТКП.Номенклатура.ЕдиницаИзмерения КАК Упаковка,
	|	&Перемещение КАК ДокументОтгрузки
	|ПОМЕСТИТЬ Обороты
	|ИЗ
	|	РегистрНакопления.ТоварыКПоступлению.Обороты(, , , ДокументПоступления = &Перемещение) КАК регТКП
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
	|		ПО регТКП.Номенклатура = ШтрихкодыНоменклатуры.Номенклатура
	|			И регТКП.Характеристика = ШтрихкодыНоменклатуры.Характеристика
	|			И регТКП.Номенклатура.ЕдиницаИзмерения = ШтрихкодыНоменклатуры.Упаковка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(СУММА(Обороты.КоличествоРОТ), 0) КАК КоличествоРОТ,
	|	ЕСТЬNULL(СУММА(Обороты.КоличествоПОТ), 0) КАК КоличествоПОТ
	|ИЗ
	|	Обороты КАК Обороты";
	Запрос = Новый Запрос(ЗапросТекст);
	Запрос.УстановитьПараметр("Перемещение", Ссылка);
	ПакетРезультатов = Запрос.ВыполнитьПакетСПромежуточнымиДанными();
	ОборотыИтоги = ПакетРезультатов[1];
	ВыборкаИтоги = ОборотыИтоги.Выбрать();
	ВыборкаИтоги.Следующий();
	ЕстьТоварыДляРОТ = ВыборкаИтоги["КоличествоРОТ"] <> 0;
	ЕстьТоварыДляПОТ = ВыборкаИтоги["КоличествоПОТ"] <> 0;
	
	// расходный ордер
	Если СкладОтправительОрдерный Тогда
		УжеЕстьРасходныйОрдер = ПроверитьНаличиеОрдераПоОснованию("РасходныйОрдерНаТовары");
		Если Статус = Перечисления.СтатусыПеремещенийТоваров.Отгружено 
			И Не УжеЕстьРасходныйОрдер 
			И ЕстьТоварыДляРОТ Тогда
			НужноСоздаватьРасходныйОрдер = Истина;	
		КонецЕсли;
	КонецЕсли;
	
	Если НужноСоздаватьРасходныйОрдер Тогда
		
		ДатаОрдера = ТекущаяДатаСеанса();
		СтруктураЗаполнения = Новый Структура();
		СтруктураЗаполнения.Вставить("Склад", лСкладОтправитель);
		СтруктураЗаполнения.Вставить("Получатель", лСкладПолучатель);
		СтруктураЗаполнения.Вставить("ДатаОтгрузки", ДатаОрдера);
		СтруктураЗаполнения.Вставить("Дата", ДатаОрдера);
		СтруктураЗаполнения.Вставить("СкладскаяОперация", Перечисления.СкладскиеОперации.ОтгрузкаПоПеремещению);
		СтруктураЗаполнения.Вставить("РежимПросмотраПоТоварам", 1);
		
		обРасхОрдер = Документы.РасходныйОрдерНаТовары.СоздатьДокумент();
		ЗаполнитьЗначенияСвойств(обРасхОрдер, СтруктураЗаполнения);
		
		ТоварыКОтгрузке = ПакетРезультатов[0].Выгрузить();
		мСтрок = ТоварыКОтгрузке.НайтиСтроки(Новый Структура("РОТ", Истина));
		Для каждого эл Из мСтрок Цикл
			нс = обРасхОрдер.ТоварыПоРаспоряжениям.Добавить();
			ЗаполнитьЗначенияСвойств(нс, эл);
			нс["Количество"] =эл["КоличествоПОТ"];
		КонецЦикла;
		ДанныеЗаполнения = Новый Структура();
		обРасхОрдер.Заполнить(ДанныеЗаполнения);
		
		Если СкладОтправительКоробочный Тогда
			ОтгружаемыеТовары = гф_ПеремещениеСервер.ДанныеЗаполненияРасходныОрдерйНаТовары( 
			Ссылка, 
			Перечисления.ДействияСоСтрокамиОрдеровНаОтгрузку.Отобрать, 
			Истина);
			ВыборкаУЛ = ОтгружаемыеТовары.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			обРасхОрдер.ОтгружаемыеТовары.Очистить();
			Пока ВыборкаУЛ.Следующий() Цикл
				нсУЛ = обРасхОрдер.ОтгружаемыеТовары.Добавить();
				нсУЛ["Количество"] = 1;
				нсУЛ["КоличествоУпаковок"] = 1;
				нсУЛ["УпаковочныйЛист"] = ВыборкаУЛ["УпаковочныйЛистРодитель"];
				нсУЛ["ЭтоУпаковочныйЛист"] = Истина;
				ВыборкаТоварыУЛ = ВыборкаУЛ.Выбрать();
				Пока ВыборкаТоварыУЛ.Следующий() Цикл
					нсТовар = обРасхОрдер.ОтгружаемыеТовары.Добавить();
					ЗаполнитьЗначенияСвойств(нсТовар, ВыборкаТоварыУл);
				КонецЦикла;
			КонецЦикла;		
			обРасхОрдер.ВсегоМест = УпаковочныеЛистыСервер.КоличествоМестВТЧ(обРасхОрдер.ОтгружаемыеТовары);
		Иначе
			ОтгружаемыеТовары = гф_ПеремещениеСервер.ДанныеЗаполненияРасходныОрдерйНаТовары( 
			Ссылка, 
			Перечисления.ДействияСоСтрокамиОрдеровНаОтгрузку.Отобрать, 
			Ложь);
			обРасхОрдер.ОтгружаемыеТовары.Загрузить(ОтгружаемыеТовары.Выгрузить());// Дописала Выгрузить(), так как передавалась не ТЗ а РезультатЗапрса
			обРасхОрдер.ВсегоМест = обРасхОрдер.ОтгружаемыеТовары.Итог("КоличествоУпаковок");
		КонецЕсли;
		
		// пересчет товаров по распоряжениям по отгруженным товарам
		тзОтгружаемыеТоварыПолная = обРасхОрдер.ОтгружаемыеТовары.Выгрузить();
		мСтрокТовары = тзОтгружаемыеТоварыПолная.НайтиСтроки(Новый Структура("ЭтоУпаковочныйЛист", Ложь));
		тзОтгружаемыеТовары = тзОтгружаемыеТоварыПолная.Скопировать(мСтрокТовары);
		тзОтгружаемыеТовары.Свернуть("Номенклатура, Характеристика, Назначение", "Количество");
		тзотгружаемыеТовары.Колонки.Добавить("Распоряжение");
		тзОтгружаемыеТовары.ЗаполнитьЗначения(Ссылка, "Распоряжение");
		обРасхОрдер.ТоварыПоРаспоряжениям.Загрузить(тзОтгружаемыеТовары);
		// ++ Галфинд_ДомнышеваКР_06_07_2023 
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee1b3b938f205b
		// Для РО должна быть заполнена ТЧ ШтрихкодыУпаковок (данные для заполнения д.б. в ТЧ гф_ШтрихкодыУпаковок)
		Если Ссылка.гф_ШтрихкодыУпаковок.Количество() > 0 Тогда
			обРасхОрдер.ШтрихкодыУпаковок.Загрузить(Ссылка.гф_ШтрихкодыУпаковок.Выгрузить());
		КонецЕсли;
		// -- Галфинд_ДомнышеваКР_06_07_2023
		обРасхОрдер.Статус = Перечисления.СтатусыРасходныхОрдеров.КОтбору;
		ПроводитьРасхОрдер = Ложь;
		Попытка
			обРасхОрдер.Записать(РежимЗаписиДокумента.Запись);
			ОбщегоНазначения.СообщитьПользователю("Записан документ " + обРасхОрдер.Ссылка);
			ПроводитьРасхОрдер = Истина;
		Исключение
			ОбщегоНазначения.СообщитьПользователю("Не удалось записать документ ""Расходный ордер на товары""");
			ОбщегоНазначения.СообщитьПользователю(ОписаниеОшибки());
		КонецПопытки;
		
		Если ПроводитьРасхОрдер Тогда
			Попытка
				обРасхОрдер.Записать(РежимЗаписиДокумента.Проведение);
				ОбщегоНазначения.СообщитьПользователю("Проведен документ (статус: ""К отбору"") " + обРасхОрдер.Ссылка);
			Исключение
				ОбщегоНазначения.СообщитьПользователю("Не удалось провести документ в статусе ""К отбору"" " + обРасхОрдер.Ссылка);
				ОбщегоНазначения.СообщитьПользователю(ОписаниеОшибки());
				//ПроводитьРасхОрдер = Ложь;
			КонецПопытки;
		КонецЕсли;
		
	КонецЕсли;
	
	// приходный ордер
	Если СкладПолучательОрдерный Тогда
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eea0d9cf0da3df
		// если склад-получатель ордерный, то ПОТ создаем всегда (если его еще нет...)
		// Галфинд Sakovich 2023/12/22
		
		//УжеЕстьПриходныйОрдер = ПроверитьНаличиеОрдераПоОснованию("ПриходныйОрдерНаТовары");
		//Если Статус = Перечисления.СтатусыПеремещенийТоваров.Принято 
		//	И Не УжеЕстьПриходныйОрдер
		//	И ЕстьТоварыДляПОТ Тогда
		//	НужноСоздаватьПриходныйОрдер = Истина;	
		//КонецЕсли; 
		НужноСоздаватьПриходныйОрдер = Не ПроверитьНаличиеОрдераПоОснованию("ПриходныйОрдерНаТовары");
		// } #wortmann
	КонецЕсли;   

	Если НужноСоздаватьПриходныйОрдер Тогда
		СтруктураПолейЗаполнения = Новый Структура();
		СтруктураПолейЗаполнения.Вставить("Склад", "СкладПолучатель");
		СтруктураПолейЗаполнения.Вставить("Распоряжение", "Ссылка");
		СтруктураПолейЗаполнения.Вставить("ДатаПоступления");
		СтруктураПолейЗаполнения.Вставить("Отправитель", "СкладОтправитель");
		СтруктураПолейЗаполнения.Вставить("ДатаВходящегоДокумента", "Дата");
		СтруктураПолейЗаполнения.Вставить("НомерВходящегоДокумента", "Номер");
		СтруктураПолейЗаполнения.Вставить("ХозяйственнаяОперация");
		
		СтруктРеквизитов = Новый ФиксированнаяСтруктура(СтруктураПолейЗаполнения);
		ЗначенияРеквизитовОснования = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, СтруктРеквизитов);
		
		ДанныеЗаполнения = Новый Структура(
		"Склад, Помещение, Распоряжение, ДатаПоступления, ЗонаПриемки, СкладскаяОперация, " + 
		"Отправитель, ДатаВходящегоДокумента, НомерВходящегоДокумента, ХозяйственнаяОперация");
		ЗаполнитьЗначенияСвойств(ДанныеЗаполнения, ЗначенияРеквизитовОснования);
		ДанныеЗаполнения["СкладскаяОперация"] = Перечисления.СкладскиеОперации.ПриемкаПоПеремещению;
		
		обПрОрдер = Документы.ПриходныйОрдерНаТовары.СоздатьДокумент();
		обПрОрдер["Дата"] = ТекущаяДатаСеанса();
		обПрОрдер.Заполнить(ДанныеЗаполнения);
		обПрОрдер["Ответственный"] = Пользователи.АвторизованныйПользователь();
		обПрОрдер["Статус"] = Перечисления.СтатусыПриходныхОрдеров.КПоступлению;
		
		Если СкладПолучательКоробочный Тогда
			ТоварыКПоступлению = гф_ПеремещениеСервер.ДанныеЗаполненияПриходныйОрдерНаТовары(Ссылка, Истина);
			ВыборкаУЛ = ТоварыКПоступлению.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			обПрОрдер.Товары.Очистить();
			Пока ВыборкаУЛ.Следующий() Цикл
				нсУЛ = обПрОрдер.Товары.Добавить();
				нсУЛ["Количество"] = 1;
				нсУЛ["КоличествоУпаковок"] = 1;
				нсУЛ["УпаковочныйЛист"] = ВыборкаУЛ["УпаковочныйЛистРодитель"];
				нсУЛ["ЭтоУпаковочныйЛист"] = Истина;
				ВыборкаТоварыУЛ = ВыборкаУЛ.Выбрать();
				Пока ВыборкаТоварыУЛ.Следующий() Цикл
					нсТовар = обПрОрдер.Товары.Добавить();
					ЗаполнитьЗначенияСвойств(нсТовар, ВыборкаТоварыУл);
				КонецЦикла;
			КонецЦикла;
			обПрОрдер.ВсегоМест = УпаковочныеЛистыСервер.КоличествоМестВТЧ(обПрОрдер.Товары);
		Иначе	
			ТоварыКПоступлению = гф_ПеремещениеСервер.ДанныеЗаполненияПриходныйОрдерНаТовары(Ссылка, Ложь);
			ТаблицаТоваровКПоступлению = ТоварыКПоступлению.Выгрузить();
			обПрОрдер.Товары.Загрузить(ТаблицаТоваровКПоступлению);
			обПрОрдер["РежимПросмотраПоТоварам"] = 1;
			обПрОрдер.ВсегоМест = обПрОрдер.Товары.Итог("КоличествоУпаковок");
		КонецЕсли;
		
		Попытка
			обПрОрдер.Записать(РежимЗаписиДокумента.Проведение);
			ОбщегоНазначения.СообщитьПользователю("Записан документ " + обПрОрдер.Ссылка);
		Исключение
			ОбщегоНазначения.СообщитьПользователю("Не удалось записать документ ""Приходный ордер на товары""");
			ОбщегоНазначения.СообщитьПользователю(ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры // } #wortmann

// #wortmann {
// Получение значение доп.реквизита гф_СозданВводомОстатков 
// Галфинд_Домнышева 2024/01/15	
Функция ДокументСозданЧерезВводОстатков()
	
	ДопРеквизит = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("ИдентификаторДляФормул",
	"гф_СозданВводомОстатков");
	ЗначениеДопРеквизита = ЭтотОбъект.ДополнительныеРеквизиты.Найти(ДопРеквизит, "Свойство");
	Если ЗначениеДопРеквизита <> Неопределено Тогда
		Возврат ЗначениеДопРеквизита.Значение;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции// } #wortmann

#КонецОбласти

#КонецЕсли