﻿
Процедура ВыставитьСчетаНаПоставку() Экспорт
	
	Возврат; // сначала переделать СформироватьСчета
	
	ДатаНачала = НачалоДня(ТекущаяДатаСеанса()); 
	ДатаОкончания = ДатаНачала + 14*86400;   
	
	СтрокаСообщений = "Дата поступления между " + Формат(ДатаНачала, "ДЛФ=D") + " и " + Формат(ДатаОкончания, "ДЛФ=D");
	ЗаписьЖурналаРегистрации("РегламентноеВыставлениеСчетов.ОтборПоДатам", УровеньЖурналаРегистрации.Информация, Метаданные.Обработки.гф_ВыставлениеСчетов,,СтрокаСообщений);

	ТаблицаЗначенийДляСоздания = ЗаполнитьТаблицуДляВыставленияСчетовНаПоставку(ДатаНачала, ДатаОкончания);
	СформироватьСчета(ТаблицаЗначенийДляСоздания)
	
КонецПроцедуры

Функция Удалить_ЗаполнитьТаблицуДляВыставленияСчетовНаПоставку(ДатаНачалаПоставки = Неопределено, ДатаОкончанияПоставки = Неопределено, 
											НомерПоставки = Неопределено, КонтрагентПоставки = Неопределено, СезонПоставки = Неопределено) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ПриобретениеТоваровУслуг.Ссылка КАК ПТУ,
	|	УпаковочныйЛист.Ссылка КАК УпаковочныйЛист,
	|	ЗаказКлиента.Ссылка КАК ЗаказКлиента,
	|	ЗаказКлиента.Договор КАК Договор,
	|	ЗаказКлиента.Договор.гф_Сезон КАК Сезон,
	|	ЗаказКлиента.Контрагент КАК Контрагент,
	|	ЗаказКлиента.Организация КАК Организация
	|ПОМЕСТИТЬ ВтДокументы
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг КАК ПриобретениеТоваровУслуг
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.УпаковочныйЛист КАК УпаковочныйЛист
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ЗаказКлиента
	|			ПО (УпаковочныйЛист.гф_Заказ = ЗаказКлиента.Ссылка)
	|		ПО (ПриобретениеТоваровУслуг.Ссылка = УпаковочныйЛист.гф_Поставка) 
	|
	| ГДЕ ПриобретениеТоваровУслуг.Проведен И ЗаказКлиента.Проведен И УпаковочныйЛист.Проведен
	| //ДобавкаУсловия 
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ЗаказКлиента
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ Разрешенные
	|	ВтДокументы.ПТУ КАК ПТУ,
	|	ВтДокументы.УпаковочныйЛист КАК УпаковочныйЛист,
	|	ВтДокументы.ЗаказКлиента КАК ЗаказКлиента,
	|	ВтДокументы.Договор КАК Договор,
	|	ВтДокументы.Сезон КАК Сезон,
	|	ВтДокументы.Контрагент КАК Контрагент,
	|	ВтДокументы.Организация КАК Организация,
	|	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
	|	ЗаказКлиентаТовары.Характеристика КАК Характеристика,
	|	ЗаказКлиентаТовары.Серия КАК Серия,
	|	ЗаказКлиентаТовары.Цена КАК Цена,
	|	ЗаказКлиентаТовары.Цена - ЕСТЬNULL(ЗаказКлиентаТовары.СуммаРучнойСкидки, 0) - ЕСТЬNULL(ЗаказКлиентаТовары.СуммаАвтоматическойСкидки, 0) КАК ЦенаСоСкидкой
	|ПОМЕСТИТЬ втДанныеПоЗаказам
	|ИЗ
	|	ВтДокументы КАК ВтДокументы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	|		ПО ВтДокументы.ЗаказКлиента = ЗаказКлиентаТовары.Ссылка
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	УпаковочныйЛист
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ  
	|	Истина Как Пометка,
	|	втДанныеПоЗаказам.ПТУ КАК ПТУ,
	|	втДанныеПоЗаказам.Договор КАК Договор,
	|	втДанныеПоЗаказам.Контрагент КАК Контрагент,
	|	втДанныеПоЗаказам.Организация КАК Организация,
	|	втДанныеПоЗаказам.Номенклатура КАК Номенклатура,
	|	СУММА(втДанныеПоЗаказам.ЦенаСоСкидкой * УпаковочныйЛистТовары.Количество) КАК Сумма
	|ИЗ
	|	втДанныеПоЗаказам КАК втДанныеПоЗаказам
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
	|		ПО втДанныеПоЗаказам.УпаковочныйЛист = УпаковочныйЛистТовары.Ссылка
	|			И втДанныеПоЗаказам.Номенклатура = УпаковочныйЛистТовары.Номенклатура
	|			И втДанныеПоЗаказам.Характеристика = УпаковочныйЛистТовары.Характеристика
	|			И втДанныеПоЗаказам.Серия = УпаковочныйЛистТовары.Серия
	| 
	|СГРУППИРОВАТЬ ПО
	|	втДанныеПоЗаказам.ПТУ,
	|	втДанныеПоЗаказам.Договор,
	|	втДанныеПоЗаказам.Контрагент,
	|	втДанныеПоЗаказам.Организация,
	|	втДанныеПоЗаказам.Номенклатура"; 
	
	
	СтрокаУсловий = " И ПриобретениеТоваровУслуг.ДатаПоступления Между &ДатаНачала и &ДатаОкончания";

	Если ЗначениеЗаполнено(ДатаНачалаПоставки) И ЗначениеЗаполнено(ДатаОкончанияПоставки) Тогда 
		Запрос.УстановитьПараметр("ДатаНачала", ДатаНачалаПоставки);  
		Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(ДатаОкончанияПоставки)); 
	Иначе 
		ДатаНачала = НачалоДня(ТекущаяДатаСеанса()); 
		Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
		Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(ДатаНачала + 14*86400)); //+2 недели
	КонецЕсли;

	Если ЗначениеЗаполнено(НомерПоставки) Тогда 
		СтрокаУсловий = " И ПриобретениеТоваровУслуг.Ссылка = &ПТУ";
		Запрос.УстановитьПараметр("ПТУ", НомерПоставки);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КонтрагентПоставки) Тогда
		
		Если ТипЗнч(КонтрагентПоставки) = Тип("СправочникСсылка.Контрагенты") Тогда
			СтрокаУсловий =  СтрокаУсловий + " И ЗаказКлиента.Контрагент = &ОтборПоКонтрагенту";
			Запрос.УстановитьПараметр("ОтборПоКонтрагенту", КонтрагентПоставки);					
		ИначеЕсли ТипЗнч(КонтрагентПоставки) = Тип("СписокЗначений") Тогда 
			СтрокаУсловий = СтрокаУсловий + " И ЗаказКлиента.Контрагент В (&СписокКонтрагентов)";
			Запрос.УстановитьПараметр("СписокКонтрагентов", КонтрагентПоставки.ВыгрузитьЗначения()); 			
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СезонПоставки) Тогда
		СтрокаУсловий =  СтрокаУсловий + " И ЗаказКлиента.Договор.гф_Сезон = &гф_Сезон";
		Запрос.УстановитьПараметр("гф_Сезон", СезонПоставки);
	КонецЕсли;
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "//ДобавкаУсловия", СтрокаУсловий);

	ТзЗапроса = Запрос.Выполнить().Выгрузить(); 
	Возврат ТзЗапроса;

КонецФункции

Функция ЗаполнитьТаблицуДляВыставленияСчетовНаПоставку(ДатаНачалаПоставки = Неопределено, ДатаОкончанияПоставки = Неопределено, 
	НомерПоставки = Неопределено, КонтрагентПоставки = Неопределено, СезонПоставки = Неопределено, флВключаяОтгруженныеУЛ = Ложь) Экспорт
	// СадомцевСА 08.02.2024 Добавил настройку "Включая отгруженные УЛ"
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eec6576f47263a

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	ПриобретениеПродукцияВКоробах.Ссылка КАК ПТУ,
	|	ПриобретениеПродукцияВКоробах.ВариантКомплектации КАК ВариантКомплектации,
	|	ПриобретениеПродукцияВКоробах.IDКороба КАК УпаковочныйЛист,
	|	ЗаказКлиента.Ссылка КАК ЗаказКлиента
	|ПОМЕСТИТЬ ВтДокументы
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг.гф_ПродукцияВКоробах КАК ПриобретениеПродукцияВКоробах
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ЗаказКлиента
	|		ПО ПриобретениеПродукцияВКоробах.IDКороба.гф_Заказ = ЗаказКлиента.Ссылка
	|ГДЕ
	|	ПриобретениеПродукцияВКоробах.Ссылка.Проведен
	|	И ПриобретениеПродукцияВКоробах.IDКороба.Проведен
	|	И ПриобретениеПродукцияВКоробах.IDКороба.гф_ТекущийОрдер = ЗНАЧЕНИЕ(Документ.РасходныйОрдерНаТовары.ПустаяСсылка)
	|	И ЗаказКлиента.Проведен
	|   //ДобавкаУсловия 
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	УпаковочныйЛистТовары.Ссылка КАК УпаковочныйЛист,
	|	УпаковочныйЛистТовары.Ссылка.гф_Комплектация КАК ВариантКомплектации,
	|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
	|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
	|	УпаковочныйЛистТовары.Серия КАК Серия,
	|	СУММА(УпаковочныйЛистТовары.Количество) КАК Количество
	|ПОМЕСТИТЬ ВтДанныеПоУпаковочнымЛистам
	|ИЗ
	|	Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
	|ГДЕ
	|	УпаковочныйЛистТовары.Ссылка В
	|			(ВЫБРАТЬ
	|				ВтДокументы.УпаковочныйЛист
	|			ИЗ
	|				ВтДокументы КАК ВтДокументы)
	|
	|СГРУППИРОВАТЬ ПО
	|	УпаковочныйЛистТовары.Ссылка,
	|	УпаковочныйЛистТовары.Номенклатура,
	|	УпаковочныйЛистТовары.Характеристика,
	|	УпаковочныйЛистТовары.Серия,
	|	УпаковочныйЛистТовары.Ссылка.гф_Комплектация
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ЗаказКлиентаТовары.Ссылка КАК ЗаказКлиента,
	|	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
	|	ЗаказКлиентаТовары.Характеристика КАК Характеристика,
	|	ЗаказКлиентаТовары.Серия КАК Серия,
	|	ЗаказКлиентаТовары.СтавкаНДС КАК СтавкаНДС,
	|	МАКСИМУМ(ЗаказКлиентаТовары.гф_ЦенаСоСкидкой) КАК ЦенаСоСкидкой
	|ПОМЕСТИТЬ ВтДанныеПоЗаказам
	|ИЗ
	|	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	|ГДЕ
	|	ЗаказКлиентаТовары.Ссылка В
	|			(ВЫБРАТЬ
	|				ВтДокументы.ЗаказКлиента
	|			ИЗ
	|				ВтДокументы КАК ВтДокументы)
	|	И (ЗаказКлиентаТовары.Номенклатура, ЗаказКлиентаТовары.Характеристика, ЗаказКлиентаТовары.Серия) В
	|			(ВЫБРАТЬ
	|				УпаковочныйЛисты.Номенклатура,
	|				УпаковочныйЛисты.Характеристика,
	|				УпаковочныйЛисты.Серия
	|			ИЗ
	|				ВтДанныеПоУпаковочнымЛистам КАК УпаковочныйЛисты)
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗаказКлиентаТовары.Ссылка,
	|	ЗаказКлиентаТовары.Номенклатура,
	|	ЗаказКлиентаТовары.Характеристика,
	|	ЗаказКлиентаТовары.Серия,
	|	ЗаказКлиентаТовары.СтавкаНДС
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВтДокументы.ПТУ КАК ПТУ,
	|	ВтДанныеПоЗаказам.ЗаказКлиента КАК ЗаказКлиента,
	|	ВтДанныеПоУпаковочнымЛистам.ВариантКомплектации КАК ВариантКомплектации,
	|	ВтДанныеПоУпаковочнымЛистам.УпаковочныйЛист КАК УпаковочныйЛист,
	|	ВтДанныеПоЗаказам.СтавкаНДС КАК СтавкаНДС,
	|	СУММА(ВтДанныеПоУпаковочнымЛистам.Количество * ВтДанныеПоЗаказам.ЦенаСоСкидкой) КАК ЦенаУпаковочногоЛиста
	|ПОМЕСТИТЬ ВтЦеныУпаоковочныхЛистов
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг.Товары КАК ПриобретениеТовары
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВтДокументы КАК ВтДокументы
	|		ПО ПриобретениеТовары.Ссылка = ВтДокументы.ПТУ
	|			И ПриобретениеТовары.гф_IDКороба = ВтДокументы.УпаковочныйЛист
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВтДанныеПоЗаказам КАК ВтДанныеПоЗаказам
	|		ПО ПриобретениеТовары.гф_ЗаказКлиента = ВтДанныеПоЗаказам.ЗаказКлиента
	|			И ПриобретениеТовары.Номенклатура = ВтДанныеПоЗаказам.Номенклатура
	|			И ПриобретениеТовары.Характеристика = ВтДанныеПоЗаказам.Характеристика
	|			И ПриобретениеТовары.Серия = ВтДанныеПоЗаказам.Серия
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВтДанныеПоУпаковочнымЛистам КАК ВтДанныеПоУпаковочнымЛистам
	|		ПО ПриобретениеТовары.гф_IDКороба = ВтДанныеПоУпаковочнымЛистам.УпаковочныйЛист
	|			И ПриобретениеТовары.Номенклатура = ВтДанныеПоУпаковочнымЛистам.Номенклатура
	|			И ПриобретениеТовары.Характеристика = ВтДанныеПоУпаковочнымЛистам.Характеристика
	|			И ПриобретениеТовары.Серия = ВтДанныеПоУпаковочнымЛистам.Серия
	|
	|СГРУППИРОВАТЬ ПО
	|	ВтДокументы.ПТУ,
	|	ВтДанныеПоЗаказам.ЗаказКлиента,
	|	ВтДанныеПоЗаказам.СтавкаНДС,
	|	ВтДанныеПоУпаковочнымЛистам.ВариантКомплектации,
	|	ВтДанныеПоУпаковочнымЛистам.УпаковочныйЛист
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВтЦеныУпаоковочныхЛистов.ПТУ КАК ПТУ,
	|	ВтЦеныУпаоковочныхЛистов.ЗаказКлиента КАК ЗаказКлиента,
	|	ВтЦеныУпаоковочныхЛистов.ВариантКомплектации КАК ВариантКомплектации,
	|	ВтЦеныУпаоковочныхЛистов.ЦенаУпаковочногоЛиста КАК ЦенаУпаковочногоЛиста,
	|	ВтЦеныУпаоковочныхЛистов.СтавкаНДС КАК СтавкаНДС,
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВтЦеныУпаоковочныхЛистов.УпаковочныйЛист) КАК КоличествоУпаковочныхЛистов
	|ПОМЕСТИТЬ ВтЦеныПоВариантам
	|ИЗ
	|	ВтЦеныУпаоковочныхЛистов КАК ВтЦеныУпаоковочныхЛистов
	|
	|СГРУППИРОВАТЬ ПО
	|	ВтЦеныУпаоковочныхЛистов.ПТУ,
	|	ВтЦеныУпаоковочныхЛистов.ЗаказКлиента,
	|	ВтЦеныУпаоковочныхЛистов.ЦенаУпаковочногоЛиста,
	|	ВтЦеныУпаоковочныхЛистов.СтавкаНДС,
	|	ВтЦеныУпаоковочныхЛистов.ВариантКомплектации
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВтЦеныПоВариантам.ПТУ КАК ПТУ,
	|	ВтЦеныПоВариантам.ЗаказКлиента КАК ЗаказКлиента, // СадомцевСА 31.01.2024
	|	ВтЦеныПоВариантам.ЗаказКлиента.Организация КАК Организация,
	|	ВтЦеныПоВариантам.ЗаказКлиента.Контрагент КАК Контрагент,
	|	ВтЦеныПоВариантам.ЗаказКлиента.Договор КАК Договор,
	|	ВтЦеныПоВариантам.ВариантКомплектации КАК ВариантКомплектации,
	|	ВтЦеныПоВариантам.ЦенаУпаковочногоЛиста КАК Цена,
	|	ВтЦеныПоВариантам.КоличествоУпаковочныхЛистов КАК Количество,
	|	ВтЦеныПоВариантам.СтавкаНДС КАК СтавкаНДС,
	|	ВтЦеныПоВариантам.КоличествоУпаковочныхЛистов * ВтЦеныПоВариантам.ЦенаУпаковочногоЛиста * ВтЦеныПоВариантам.СтавкаНДС.Ставка / 100 КАК СуммаНДС,
	|	ВтЦеныПоВариантам.КоличествоУпаковочныхЛистов * ВтЦеныПоВариантам.ЦенаУпаковочногоЛиста КАК СуммаБезНДС,
	|	ВтЦеныПоВариантам.КоличествоУпаковочныхЛистов * ВтЦеныПоВариантам.ЦенаУпаковочногоЛиста * ВтЦеныПоВариантам.СтавкаНДС.Ставка / 100 + ВтЦеныПоВариантам.КоличествоУпаковочныхЛистов * ВтЦеныПоВариантам.ЦенаУпаковочногоЛиста КАК Сумма
	|ПОМЕСТИТЬ ВтДанныеКВыставлению
	|ИЗ
	|	ВтЦеныПоВариантам КАК ВтЦеныПоВариантам
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	СчетНаОплатуТоварыВКоробах.Ссылка.гф_НомерПоставки КАК ПТУ,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Организация КАК Организация,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Контрагент КАК Контрагент,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Договор КАК Договор,
	|	СчетНаОплатуТоварыВКоробах.ВариантКомплектации КАК ВариантКомплектации,
	|	СчетНаОплатуТоварыВКоробах.ЗаказКлиента КАК ЗаказКлиента, // СадомцевСА 31.01.2024
	|	СчетНаОплатуТоварыВКоробах.Цена КАК Цена,
	|	СчетНаОплатуТоварыВКоробах.СтавкаНДС КАК СтавкаНДС,
	|	СУММА(СчетНаОплатуТоварыВКоробах.Сумма) КАК Сумма
	|ПОМЕСТИТЬ ВтВыставленныеСчета
	|ИЗ
	|	Документ.СчетНаОплатуКлиенту.гф_ТоварыВКоробах КАК СчетНаОплатуТоварыВКоробах
	|ГДЕ
	|	НЕ СчетНаОплатуТоварыВКоробах.Ссылка.ПометкаУдаления
	|	И (СчетНаОплатуТоварыВКоробах.Ссылка.гф_НомерПоставки, СчетНаОплатуТоварыВКоробах.Ссылка.Организация, СчетНаОплатуТоварыВКоробах.Ссылка.Контрагент, СчетНаОплатуТоварыВКоробах.Ссылка.Договор) В
	|			(ВЫБРАТЬ
	|				КВыставлению.ПТУ,
	|				КВыставлению.Организация,
	|				КВыставлению.Контрагент,
	|				КВыставлению.Договор
	|			ИЗ
	|				ВтДанныеКВыставлению КАК КВыставлению)
	|
	|СГРУППИРОВАТЬ ПО
	|	СчетНаОплатуТоварыВКоробах.Ссылка.гф_НомерПоставки,
	|	СчетНаОплатуТоварыВКоробах.ВариантКомплектации,
	|	СчетНаОплатуТоварыВКоробах.ЗаказКлиента, // СадомцевСА 31.01.2024
	|	СчетНаОплатуТоварыВКоробах.Цена,
	|	СчетНаОплатуТоварыВКоробах.СтавкаНДС,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Организация,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Контрагент,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Договор
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВтДанныеКВыставлению.ПТУ КАК ПТУ,
	|	ВтДанныеКВыставлению.ЗаказКлиента КАК ЗаказКлиента, // СадомцевСА 31.01.2024
	|	ВтДанныеКВыставлению.Организация КАК Организация,
	|	ВтДанныеКВыставлению.Контрагент КАК Контрагент,
	|	ВтДанныеКВыставлению.Договор КАК Договор,
	|	ВтДанныеКВыставлению.ВариантКомплектации КАК ВариантКомплектации,
	|	ВтДанныеКВыставлению.Цена КАК Цена,
	|	ВтДанныеКВыставлению.Количество КАК Количество,
	|	ВтДанныеКВыставлению.СтавкаНДС КАК СтавкаНДС,
	|	ВтДанныеКВыставлению.СуммаНДС КАК СуммаНДС,
	|	ВтДанныеКВыставлению.СуммаБезНДС КАК СуммаБезНДС,
	|	ВтДанныеКВыставлению.Сумма КАК Сумма,
	|	ЕСТЬNULL(ВтВыставленныеСчета.Сумма, 0) КАК СуммаВыставленныхСчетов
	|ИЗ
	|	ВтДанныеКВыставлению КАК ВтДанныеКВыставлению
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВтВыставленныеСчета КАК ВтВыставленныеСчета
	|		ПО ВтДанныеКВыставлению.ПТУ = ВтВыставленныеСчета.ПТУ
	|			И ВтДанныеКВыставлению.Организация = ВтВыставленныеСчета.Организация
	|			И ВтДанныеКВыставлению.Контрагент = ВтВыставленныеСчета.Контрагент
	|			И ВтДанныеКВыставлению.Договор = ВтВыставленныеСчета.Договор
	|			И ВтДанныеКВыставлению.ВариантКомплектации = ВтВыставленныеСчета.ВариантКомплектации
	|			И ВтДанныеКВыставлению.ЗаказКлиента = ВтВыставленныеСчета.ЗаказКлиента // СадомцевСА 31.01.2024
	|			И ВтДанныеКВыставлению.Цена = ВтВыставленныеСчета.Цена
	|			И ВтДанныеКВыставлению.СтавкаНДС = ВтВыставленныеСчета.СтавкаНДС
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВтДанныеКВыставлению.Контрагент.Наименование,
	|	ВтДанныеКВыставлению.Договор.Наименование,
	|	ВтДанныеКВыставлению.ПТУ.Представление,
	|	ВтДанныеКВыставлению.ВариантКомплектации.Наименование";
	
	Если ЗначениеЗаполнено(НомерПоставки) Тогда
		
		СтрокаУсловий = " И ПриобретениеПродукцияВКоробах.Ссылка = &ПТУ";
		Запрос.УстановитьПараметр("ПТУ", НомерПоставки);
		
	Иначе
		
		СтрокаУсловий = " И ПриобретениеПродукцияВКоробах.Ссылка.Дата Между &ДатаНачала и &ДатаОкончания";

		Если ЗначениеЗаполнено(ДатаНачалаПоставки) И ЗначениеЗаполнено(ДатаОкончанияПоставки) Тогда 
			Запрос.УстановитьПараметр("ДатаНачала", ДатаНачалаПоставки);  
			Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(ДатаОкончанияПоставки)); 
		Иначе 
			ДатаНачала = НачалоДня(ТекущаяДатаСеанса()); 
			Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
			Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(ДатаНачала + 14*86400)); //+2 недели
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КонтрагентПоставки) Тогда
		
		Если ТипЗнч(КонтрагентПоставки) = Тип("СправочникСсылка.Контрагенты") Тогда
			СтрокаУсловий =  СтрокаУсловий + " И ЗаказКлиента.Контрагент = &ОтборПоКонтрагенту";
			Запрос.УстановитьПараметр("ОтборПоКонтрагенту", КонтрагентПоставки);					
		ИначеЕсли ТипЗнч(КонтрагентПоставки) = Тип("СписокЗначений") Тогда 
			СтрокаУсловий = СтрокаУсловий + " И ЗаказКлиента.Контрагент В (&СписокКонтрагентов)";
			Запрос.УстановитьПараметр("СписокКонтрагентов", КонтрагентПоставки.ВыгрузитьЗначения()); 			
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СезонПоставки) Тогда
		СтрокаУсловий =  СтрокаУсловий + " И ЗаказКлиента.Договор.гф_Сезон = &гф_Сезон";
		Запрос.УстановитьПараметр("гф_Сезон", СезонПоставки);
	КонецЕсли;
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "//ДобавкаУсловия", СтрокаУсловий);
	// ++ СадомцевСА 08.02.2024 Добавил настройку "Включая отгруженные УЛ"
	Если флВключаяОтгруженныеУЛ Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст,
    	"ПриобретениеПродукцияВКоробах.IDКороба.гф_ТекущийОрдер = ЗНАЧЕНИЕ(Документ.РасходныйОрдерНаТовары.ПустаяСсылка)",
		"ИСТИНА");
	КонецЕсли;
	// -- СадомцевСА 08.02.2024

	ТзЗапроса = Запрос.Выполнить().Выгрузить(); 
	Возврат ТзЗапроса;

КонецФункции

Процедура СформироватьСчета(ТаблицаЗначенийДляСоздания, ЗапускИзФормы = Истина)
	
		Для Каждого Элемент Из ТаблицаЗначенийДляСоздания Цикл 
			
			СчетСсылка = НайтиСчетНаОплатуПоПоставке(Элемент.ПТУ, Элемент.Контрагент, Элемент.Договор, Элемент.Номенклатура);
			
			Если СчетСсылка = Неопределено Тогда
				ДокументСчет = Документы.СчетНаОплатуКлиенту.СоздатьДокумент();
			Иначе
				ДокументСчет = СчетСсылка.ПолучитьОбъект();
			КонецЕсли;
			
			ДокументСчет.Дата = ТекущаяДата();
			ДокументСчет.Организация = Элемент.Организация;
			ДокументСчет.СуммаДокумента = Элемент.Сумма;
			
			ДоговорКонтрагента = Элемент.Договор;
			ДокументСчет.Валюта = ДоговорКонтрагента.ВалютаВзаиморасчетов;
			ДокументСчет.БанковскийСчет = ДоговорКонтрагента.БанковскийСчет;
			ДокументСчет.Договор = ДоговорКонтрагента; 
			ДокументСчет.ДокументОснование = ДоговорКонтрагента;
			ДокументСчет.ЧастичнаяОплата = Истина;    
			
			ДокументСчет.НазначениеПлатежа = Элемент.Номенклатура;
			ДокументСчет.Контрагент = Элемент.Контрагент; 
			ДокументСчет.Партнер = Элемент.Контрагент.Партнер; 
			
			ДокументСчет.гф_НомерПоставки = Элемент.ПТУ;
			
			ДокументСчет.ЭтапыГрафикаОплаты.Очистить();
			
			СтрокаПлатежа = ДокументСчет.ЭтапыГрафикаОплаты.Добавить();
			СтрокаПлатежа.ДатаПлатежа = ДокументСчет.Дата;
			СтрокаПлатежа.ПроцентПлатежа = 100;
			СтрокаПлатежа.СуммаПлатежа = Элемент.Сумма;
			
			Попытка
				ДокументСчет.Записать(РежимЗаписиДокумента.Проведение);
			Исключение
				ОписаниеОшибки = ОписаниеОшибки(); 
				СтрокаСообщений = "Ошибка при записи счета для документа: " + Элемент.ПТУ + " - " + ОписаниеОшибки;
				ЗаписьЖурналаРегистрации("РегламентноеВыставлениеСчетов.Ошибка", УровеньЖурналаРегистрации.Ошибка, Метаданные.Документы.СчетНаОплатуКлиент,,СтрокаСообщений);
			КонецПопытки;
			
	КонецЦикла;

КонецПроцедуры  

Функция НайтиСчетНаОплатуПоПоставке(ДокументПТУ, КонтрагентСчета, ДоговорСчета, НазначениеПлатежа) 
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	СчетНаОплатуКлиенту.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.СчетНаОплатуКлиенту КАК СчетНаОплатуКлиенту
	|ГДЕ
	|	СчетНаОплатуКлиенту.гф_НомерПоставки = &ДокументПТУ
	|	И СчетНаОплатуКлиенту.Контрагент = &КонтрагентСчета
	|	И СчетНаОплатуКлиенту.Договор = &ДоговорСчета
	|	И СчетНаОплатуКлиенту.НазначениеПлатежа ПОДОБНО &НазначениеПлатежа
	|	И НЕ СчетНаОплатуКлиенту.ПометкаУдаления";
	Запрос.УстановитьПараметр("ДокументПТУ", ДокументПТУ); 
	Запрос.УстановитьПараметр("КонтрагентСчета", КонтрагентСчета);
	Запрос.УстановитьПараметр("ДоговорСчета", ДоговорСчета);
	Запрос.УстановитьПараметр("НазначениеПлатежа", НазначениеПлатежа.Наименование + "%"); 
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		
		Возврат Неопределено;   
		
	Иначе 
		
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		
		Возврат Выборка.Ссылка; 
		
	КонецЕсли;
		
КонецФункции

Функция ЗаполнитьТаблицуДляВыставленияСчетовНаПоставкуУЛ(МассивЗаказы, МассивУЛ) Экспорт
	// СадомцевСА 08.02.2024 Добавил настройку "Включая отгруженные УЛ"
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eec6576f47263a

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивЗаказы", МассивЗаказы);
	Запрос.УстановитьПараметр("МассивУЛ", МассивУЛ);
	Запрос.Текст = "
	//"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	//|	ПриобретениеПродукцияВКоробах.Ссылка КАК ПТУ,
	//|	ПриобретениеПродукцияВКоробах.ВариантКомплектации КАК ВариантКомплектации,
	//|	ПриобретениеПродукцияВКоробах.IDКороба КАК УпаковочныйЛист,
	//|	ЗаказКлиента.Ссылка КАК ЗаказКлиента
	//|ПОМЕСТИТЬ ВтДокументы
	//|ИЗ
	//|	Документ.ПриобретениеТоваровУслуг.гф_ПродукцияВКоробах КАК ПриобретениеПродукцияВКоробах
	//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ЗаказКлиента
	//|		ПО ПриобретениеПродукцияВКоробах.IDКороба.гф_Заказ = ЗаказКлиента.Ссылка
	//|ГДЕ
	//|	ПриобретениеПродукцияВКоробах.Ссылка.Проведен
	//|	И ПриобретениеПродукцияВКоробах.IDКороба.Проведен
	//|	И ПриобретениеПродукцияВКоробах.IDКороба.гф_ТекущийОрдер = ЗНАЧЕНИЕ(Документ.РасходныйОрдерНаТовары.ПустаяСсылка)
	//|	И ЗаказКлиента.Проведен
	//|   //ДобавкаУсловия 
	//|;
	//|
	//|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	УпаковочныйЛистТовары.Ссылка КАК УпаковочныйЛист,
	|	УпаковочныйЛистТовары.Ссылка.гф_Комплектация КАК ВариантКомплектации,
	|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
	|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
	|	УпаковочныйЛистТовары.Серия КАК Серия,
	|	СУММА(УпаковочныйЛистТовары.Количество) КАК Количество
	|ПОМЕСТИТЬ ВтДанныеПоУпаковочнымЛистам
	|ИЗ
	|	Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
	|ГДЕ
	|	УпаковочныйЛистТовары.Ссылка В (&МассивУЛ)
	//|			(ВЫБРАТЬ
	//|				ВтДокументы.УпаковочныйЛист
	//|			ИЗ
	//|				ВтДокументы КАК ВтДокументы)
	|
	|СГРУППИРОВАТЬ ПО
	|	УпаковочныйЛистТовары.Ссылка,
	|	УпаковочныйЛистТовары.Номенклатура,
	|	УпаковочныйЛистТовары.Характеристика,
	|	УпаковочныйЛистТовары.Серия,
	|	УпаковочныйЛистТовары.Ссылка.гф_Комплектация
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ЗаказКлиентаТовары.Ссылка КАК ЗаказКлиента,
	|	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
	|	ЗаказКлиентаТовары.Характеристика КАК Характеристика,
	|	ЗаказКлиентаТовары.Серия КАК Серия,
	|	ЗаказКлиентаТовары.СтавкаНДС КАК СтавкаНДС,
	|	МАКСИМУМ(ЗаказКлиентаТовары.гф_ЦенаСоСкидкой) КАК ЦенаСоСкидкой
	|ПОМЕСТИТЬ ВтДанныеПоЗаказам
	|ИЗ
	|	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	|ГДЕ
	|	ЗаказКлиентаТовары.Ссылка В (&МассивЗаказы)
	//|			(ВЫБРАТЬ
	//|				ВтДокументы.ЗаказКлиента
	//|			ИЗ
	//|				ВтДокументы КАК ВтДокументы)
	|	И (ЗаказКлиентаТовары.Номенклатура, ЗаказКлиентаТовары.Характеристика, ЗаказКлиентаТовары.Серия) В
	|			(ВЫБРАТЬ
	|				УпаковочныйЛисты.Номенклатура,
	|				УпаковочныйЛисты.Характеристика,
	|				УпаковочныйЛисты.Серия
	|			ИЗ
	|				ВтДанныеПоУпаковочнымЛистам КАК УпаковочныйЛисты)
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗаказКлиентаТовары.Ссылка,
	|	ЗаказКлиентаТовары.Номенклатура,
	|	ЗаказКлиентаТовары.Характеристика,
	|	ЗаказКлиентаТовары.Серия,
	|	ЗаказКлиентаТовары.СтавкаНДС
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	//|	ВтДокументы.ПТУ КАК ПТУ,
	|	ЗНАЧЕНИЕ(Документ.ПриобретениеТоваровУслуг.ПустаяСсылка) КАК ПТУ,
	|	ВтДанныеПоЗаказам.ЗаказКлиента КАК ЗаказКлиента,
	|	ВтДанныеПоУпаковочнымЛистам.ВариантКомплектации КАК ВариантКомплектации,
	|	ВтДанныеПоУпаковочнымЛистам.УпаковочныйЛист КАК УпаковочныйЛист,
	|	ВтДанныеПоЗаказам.СтавкаНДС КАК СтавкаНДС,
	|	СУММА(ВтДанныеПоУпаковочнымЛистам.Количество * ВтДанныеПоЗаказам.ЦенаСоСкидкой) КАК ЦенаУпаковочногоЛиста
	|ПОМЕСТИТЬ ВтЦеныУпаоковочныхЛистов
	|ИЗ
	//|	Документ.ПриобретениеТоваровУслуг.Товары КАК ПриобретениеТовары
	//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВтДокументы КАК ВтДокументы
	//|		ПО ПриобретениеТовары.Ссылка = ВтДокументы.ПТУ
	//|			И ПриобретениеТовары.гф_IDКороба = ВтДокументы.УпаковочныйЛист
	//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВтДанныеПоЗаказам КАК ВтДанныеПоЗаказам
	//|		ПО ПриобретениеТовары.гф_ЗаказКлиента = ВтДанныеПоЗаказам.ЗаказКлиента
	//|			И ПриобретениеТовары.Номенклатура = ВтДанныеПоЗаказам.Номенклатура
	//|			И ПриобретениеТовары.Характеристика = ВтДанныеПоЗаказам.Характеристика
	//|			И ПриобретениеТовары.Серия = ВтДанныеПоЗаказам.Серия
	//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВтДанныеПоУпаковочнымЛистам КАК ВтДанныеПоУпаковочнымЛистам
	//|		ПО ПриобретениеТовары.гф_IDКороба = ВтДанныеПоУпаковочнымЛистам.УпаковочныйЛист
	//|			И ПриобретениеТовары.Номенклатура = ВтДанныеПоУпаковочнымЛистам.Номенклатура
	//|			И ПриобретениеТовары.Характеристика = ВтДанныеПоУпаковочнымЛистам.Характеристика
	//|			И ПриобретениеТовары.Серия = ВтДанныеПоУпаковочнымЛистам.Серия
	|	ВтДанныеПоУпаковочнымЛистам КАК ВтДанныеПоУпаковочнымЛистам
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВтДанныеПоЗаказам КАК ВтДанныеПоЗаказам
	|		ПО ВтДанныеПоУпаковочнымЛистам.УпаковочныйЛист.гф_Заказ = ВтДанныеПоЗаказам.ЗаказКлиента
	|			И ВтДанныеПоУпаковочнымЛистам.Номенклатура = ВтДанныеПоЗаказам.Номенклатура
	|			И ВтДанныеПоУпаковочнымЛистам.Характеристика = ВтДанныеПоЗаказам.Характеристика
	|			И ВтДанныеПоУпаковочнымЛистам.Серия = ВтДанныеПоЗаказам.Серия
	|
	|СГРУППИРОВАТЬ ПО
	//|	ВтДокументы.ПТУ,
	|	ВтДанныеПоЗаказам.ЗаказКлиента,
	|	ВтДанныеПоЗаказам.СтавкаНДС,
	|	ВтДанныеПоУпаковочнымЛистам.ВариантКомплектации,
	|	ВтДанныеПоУпаковочнымЛистам.УпаковочныйЛист
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВтЦеныУпаоковочныхЛистов.ПТУ КАК ПТУ,
	|	ВтЦеныУпаоковочныхЛистов.ЗаказКлиента КАК ЗаказКлиента,
	|	ВтЦеныУпаоковочныхЛистов.ВариантКомплектации КАК ВариантКомплектации,
	|	ВтЦеныУпаоковочныхЛистов.ЦенаУпаковочногоЛиста КАК ЦенаУпаковочногоЛиста,
	|	ВтЦеныУпаоковочныхЛистов.СтавкаНДС КАК СтавкаНДС,
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВтЦеныУпаоковочныхЛистов.УпаковочныйЛист) КАК КоличествоУпаковочныхЛистов
	|ПОМЕСТИТЬ ВтЦеныПоВариантам
	|ИЗ
	|	ВтЦеныУпаоковочныхЛистов КАК ВтЦеныУпаоковочныхЛистов
	|
	|СГРУППИРОВАТЬ ПО
	|	ВтЦеныУпаоковочныхЛистов.ПТУ,
	|	ВтЦеныУпаоковочныхЛистов.ЗаказКлиента,
	|	ВтЦеныУпаоковочныхЛистов.ЦенаУпаковочногоЛиста,
	|	ВтЦеныУпаоковочныхЛистов.СтавкаНДС,
	|	ВтЦеныУпаоковочныхЛистов.ВариантКомплектации
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВтЦеныПоВариантам.ПТУ КАК ПТУ,
	|	ВтЦеныПоВариантам.ЗаказКлиента КАК ЗаказКлиента, // СадомцевСА 31.01.2024
	|	ВтЦеныПоВариантам.ЗаказКлиента.Организация КАК Организация,
	|	ВтЦеныПоВариантам.ЗаказКлиента.Контрагент КАК Контрагент,
	|	ВтЦеныПоВариантам.ЗаказКлиента.Договор КАК Договор,
	|	ВтЦеныПоВариантам.ВариантКомплектации КАК ВариантКомплектации,
	|	ВтЦеныПоВариантам.ЦенаУпаковочногоЛиста КАК Цена,
	|	ВтЦеныПоВариантам.КоличествоУпаковочныхЛистов КАК Количество,
	|	ВтЦеныПоВариантам.СтавкаНДС КАК СтавкаНДС,
	|	ВтЦеныПоВариантам.КоличествоУпаковочныхЛистов * ВтЦеныПоВариантам.ЦенаУпаковочногоЛиста * ВтЦеныПоВариантам.СтавкаНДС.Ставка / 100 КАК СуммаНДС,
	|	ВтЦеныПоВариантам.КоличествоУпаковочныхЛистов * ВтЦеныПоВариантам.ЦенаУпаковочногоЛиста КАК СуммаБезНДС,
	|	ВтЦеныПоВариантам.КоличествоУпаковочныхЛистов * ВтЦеныПоВариантам.ЦенаУпаковочногоЛиста * ВтЦеныПоВариантам.СтавкаНДС.Ставка / 100 + ВтЦеныПоВариантам.КоличествоУпаковочныхЛистов * ВтЦеныПоВариантам.ЦенаУпаковочногоЛиста КАК Сумма
	|ПОМЕСТИТЬ ВтДанныеКВыставлению
	|ИЗ
	|	ВтЦеныПоВариантам КАК ВтЦеныПоВариантам
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	СчетНаОплатуТоварыВКоробах.Ссылка.гф_НомерПоставки КАК ПТУ,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Организация КАК Организация,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Контрагент КАК Контрагент,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Договор КАК Договор,
	|	СчетНаОплатуТоварыВКоробах.ВариантКомплектации КАК ВариантКомплектации,
	|	СчетНаОплатуТоварыВКоробах.ЗаказКлиента КАК ЗаказКлиента, // СадомцевСА 31.01.2024
	|	СчетНаОплатуТоварыВКоробах.Цена КАК Цена,
	|	СчетНаОплатуТоварыВКоробах.СтавкаНДС КАК СтавкаНДС,
	|	СУММА(СчетНаОплатуТоварыВКоробах.Сумма) КАК Сумма
	|ПОМЕСТИТЬ ВтВыставленныеСчета
	|ИЗ
	|	Документ.СчетНаОплатуКлиенту.гф_ТоварыВКоробах КАК СчетНаОплатуТоварыВКоробах
	|ГДЕ
	|	НЕ СчетНаОплатуТоварыВКоробах.Ссылка.ПометкаУдаления
	|	И (СчетНаОплатуТоварыВКоробах.Ссылка.гф_НомерПоставки, СчетНаОплатуТоварыВКоробах.Ссылка.Организация, СчетНаОплатуТоварыВКоробах.Ссылка.Контрагент, СчетНаОплатуТоварыВКоробах.Ссылка.Договор) В
	|			(ВЫБРАТЬ
	|				КВыставлению.ПТУ,
	|				КВыставлению.Организация,
	|				КВыставлению.Контрагент,
	|				КВыставлению.Договор
	|			ИЗ
	|				ВтДанныеКВыставлению КАК КВыставлению)
	|
	|СГРУППИРОВАТЬ ПО
	|	СчетНаОплатуТоварыВКоробах.Ссылка.гф_НомерПоставки,
	|	СчетНаОплатуТоварыВКоробах.ВариантКомплектации,
	|	СчетНаОплатуТоварыВКоробах.ЗаказКлиента, // СадомцевСА 31.01.2024
	|	СчетНаОплатуТоварыВКоробах.Цена,
	|	СчетНаОплатуТоварыВКоробах.СтавкаНДС,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Организация,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Контрагент,
	|	СчетНаОплатуТоварыВКоробах.Ссылка.Договор
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВтДанныеКВыставлению.ПТУ КАК ПТУ,
	|	ВтДанныеКВыставлению.ЗаказКлиента КАК ЗаказКлиента, // СадомцевСА 31.01.2024
	|	ВтДанныеКВыставлению.Организация КАК Организация,
	|	ВтДанныеКВыставлению.Контрагент КАК Контрагент,
	|	ВтДанныеКВыставлению.Договор КАК Договор,
	|	ВтДанныеКВыставлению.ВариантКомплектации КАК ВариантКомплектации,
	|	ВтДанныеКВыставлению.Цена КАК Цена,
	|	ВтДанныеКВыставлению.Количество КАК Количество,
	|	ВтДанныеКВыставлению.СтавкаНДС КАК СтавкаНДС,
	|	ВтДанныеКВыставлению.СуммаНДС КАК СуммаНДС,
	|	ВтДанныеКВыставлению.СуммаБезНДС КАК СуммаБезНДС,
	|	ВтДанныеКВыставлению.Сумма КАК Сумма,
	|	ЕСТЬNULL(ВтВыставленныеСчета.Сумма, 0) КАК СуммаВыставленныхСчетов
	|ИЗ
	|	ВтДанныеКВыставлению КАК ВтДанныеКВыставлению
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВтВыставленныеСчета КАК ВтВыставленныеСчета
	|		ПО ВтДанныеКВыставлению.ПТУ = ВтВыставленныеСчета.ПТУ
	|			И ВтДанныеКВыставлению.Организация = ВтВыставленныеСчета.Организация
	|			И ВтДанныеКВыставлению.Контрагент = ВтВыставленныеСчета.Контрагент
	|			И ВтДанныеКВыставлению.Договор = ВтВыставленныеСчета.Договор
	|			И ВтДанныеКВыставлению.ВариантКомплектации = ВтВыставленныеСчета.ВариантКомплектации
	|			И ВтДанныеКВыставлению.ЗаказКлиента = ВтВыставленныеСчета.ЗаказКлиента // СадомцевСА 31.01.2024
	|			И ВтДанныеКВыставлению.Цена = ВтВыставленныеСчета.Цена
	|			И ВтДанныеКВыставлению.СтавкаНДС = ВтВыставленныеСчета.СтавкаНДС
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВтДанныеКВыставлению.Контрагент.Наименование,
	|	ВтДанныеКВыставлению.Договор.Наименование,
	|	ВтДанныеКВыставлению.ПТУ.Представление,
	|	ВтДанныеКВыставлению.ВариантКомплектации.Наименование";
	
	//Если ЗначениеЗаполнено(НомерПоставки) Тогда
	//	
	//	СтрокаУсловий = " И ПриобретениеПродукцияВКоробах.Ссылка = &ПТУ";
	//	Запрос.УстановитьПараметр("ПТУ", НомерПоставки);
	//	
	//Иначе
	//	
	//	СтрокаУсловий = " И ПриобретениеПродукцияВКоробах.Ссылка.Дата Между &ДатаНачала и &ДатаОкончания";

	//	Если ЗначениеЗаполнено(ДатаНачалаПоставки) И ЗначениеЗаполнено(ДатаОкончанияПоставки) Тогда 
	//		Запрос.УстановитьПараметр("ДатаНачала", ДатаНачалаПоставки);  
	//		Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(ДатаОкончанияПоставки)); 
	//	Иначе 
	//		ДатаНачала = НачалоДня(ТекущаяДатаСеанса()); 
	//		Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	//		Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(ДатаНачала + 14*86400)); //+2 недели
	//	КонецЕсли;
	//	
	//КонецЕсли;
	//
	//Если ЗначениеЗаполнено(КонтрагентПоставки) Тогда
	//	
	//	Если ТипЗнч(КонтрагентПоставки) = Тип("СправочникСсылка.Контрагенты") Тогда
	//		СтрокаУсловий =  СтрокаУсловий + " И ЗаказКлиента.Контрагент = &ОтборПоКонтрагенту";
	//		Запрос.УстановитьПараметр("ОтборПоКонтрагенту", КонтрагентПоставки);					
	//	ИначеЕсли ТипЗнч(КонтрагентПоставки) = Тип("СписокЗначений") Тогда 
	//		СтрокаУсловий = СтрокаУсловий + " И ЗаказКлиента.Контрагент В (&СписокКонтрагентов)";
	//		Запрос.УстановитьПараметр("СписокКонтрагентов", КонтрагентПоставки.ВыгрузитьЗначения()); 			
	//	КонецЕсли;
	//	
	//КонецЕсли;
	//
	//Если ЗначениеЗаполнено(СезонПоставки) Тогда
	//	СтрокаУсловий =  СтрокаУсловий + " И ЗаказКлиента.Договор.гф_Сезон = &гф_Сезон";
	//	Запрос.УстановитьПараметр("гф_Сезон", СезонПоставки);
	//КонецЕсли;
	//Запрос.Текст = СтрЗаменить(Запрос.Текст, "//ДобавкаУсловия", СтрокаУсловий);
	//// ++ СадомцевСА 08.02.2024 Добавил настройку "Включая отгруженные УЛ"
	//Если флВключаяОтгруженныеУЛ Тогда
	//	Запрос.Текст = СтрЗаменить(Запрос.Текст,
	//	"ПриобретениеПродукцияВКоробах.IDКороба.гф_ТекущийОрдер = ЗНАЧЕНИЕ(Документ.РасходныйОрдерНаТовары.ПустаяСсылка)",
	//	"ИСТИНА");
	//КонецЕсли;
	//// -- СадомцевСА 08.02.2024

	ТзЗапроса = Запрос.Выполнить().Выгрузить(); 
	Возврат ТзЗапроса;

КонецФункции
