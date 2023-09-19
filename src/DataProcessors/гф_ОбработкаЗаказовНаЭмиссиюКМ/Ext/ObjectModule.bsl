﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область СлужебныйПрограммныйИнтерфейс

Процедура СоздатьДокументыЗаказНаЭмиссиюКодовМаркировки(РезультатОбработки) Экспорт
	УспешноеВыполнение = Истина;
	
	мПТУДляОбработки = ПолучитьСписокОбрабатываемыхПоступлений();
	мЗаказовДляОбработки = ПолучитьСписокОбрабатываемыхЗаказовПоставщику();
	ИтоговыйМассивДляОбработки = Новый Массив;
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(ИтоговыйМассивДляОбработки, мПТУДляОбработки, Истина);
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(ИтоговыйМассивДляОбработки, мЗаказовДляОбработки, Истина);
	
	Если ИтоговыйМассивДляОбработки.ВГраница() = -1 Тогда
		Возврат;
	КонецЕсли;

	Для каждого Эл Из ИтоговыйМассивДляОбработки Цикл
		
		// Для каждого учетного документа создаются документы Заказов на эмиссию кодов маркировки
		// с учетом того, чтобы в каждом документе эмиссии было не более 10 строк.
		// например: в поступлении 300 строк - создается 30 заказов на эмиссию.
		
		мМассивовСтрок = Новый Массив;	
		
		тчТовары = Эл.Товары.Выгрузить(); 
		
		// vvv Галфинд \ Sakovich 18.09.2023
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee55f81a6bfaf0
		тчТовары.Свернуть("Номенклатура, Характеристика", "Количество, КоличествоУпаковок");
		// ^^^ Галфинд \ Sakovich 18.09.2023
		
		мСтрокДляОдногоДокумента = Новый Массив;
		
		Сч = 1;
		Обработано = 0;
		КоличествоСтрок = тчТовары.Количество();
		Для каждого стрТч Из тчТовары Цикл
			Обработано = Обработано + 1;
			ОбобенностьУчета = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(стрТч["Номенклатура"], "ОсобенностьУчета");
			Если ОбобенностьУчета = Перечисления.ОсобенностиУчетаНоменклатуры.ОбувнаяПродукция Тогда
				Если Сч <= Мин(10, КоличествоСтрок) Тогда
					мСтрокДляОдногоДокумента.Добавить(стрТч);
				Иначе
					Сч = 1;
					мМассивовСтрок.Добавить(мСтрокДляОдногоДокумента);
					мСтрокДляОдногоДокумента = Новый Массив;
					мСтрокДляОдногоДокумента.Добавить(стрТч);
				КонецЕсли;
				Сч = Сч + 1;
			КонецЕсли;
			
		КонецЦикла;
		Если Обработано = КоличествоСтрок И мСтрокДляОдногоДокумента.ВГраница() > -1 Тогда
			мМассивовСтрок.Добавить(мСтрокДляОдногоДокумента);
		КонецЕсли;
		
		Для каждого ЭлМассив Из мМассивовСтрок Цикл
			
			тзТоварыДляОбработки = тчТовары.Скопировать(ЭлМассив);
			ДопПараметры = Новый Структура();
			ДопПараметры.Вставить("Товары", тзТоварыДляОбработки);
			Результат = гф_ЭмиссияКодовМаркировкиВызовСервера.гф_СоздатьЗаказНаЭмиссиюКодовМаркировки(Эл, ДопПараметры);

			Если Не (ЗначениеЗаполнено(Результат["ЗаказНаЭмиссиюКодовМаркировкиСУЗ"]) 
				И Результат["ЗаказКодовВозможен"]) Тогда
				УспешноеВыполнение = Ложь;
			КонецЕсли;
		КонецЦикла;
		
	КонецЦикла;

	
	Если УспешноеВыполнение Тогда
		РезультатОбработки = Истина;
	Иначе
		РезультатОбработки = Ложь;
	КонецЕсли;
	
КонецПроцедуры

// Возвращаемое значение - <массив> - массив ссылок ДокументСсылка.ПриобретениеТоваровУслуг
Функция ПолучитьСписокОбрабатываемыхПоступлений() Экспорт
	Запрос = Новый Запрос("ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПриобретениеТоваровУслуг.Ссылка КАК докПТУ
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг КАК ПриобретениеТоваровУслуг
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК ЗаказНаЭмиссиюКодовМаркировкиСУЗ
	|		ПО (ПриобретениеТоваровУслуг.Ссылка = ЗаказНаЭмиссиюКодовМаркировкиСУЗ.ДокументОснование)
	|ГДЕ
	|	ПриобретениеТоваровУслуг.Проведен
	|				И ПриобретениеТоваровУслуг.гф_ЗаказатьКМ
	|				И НЕ ПриобретениеТоваровУслуг.гф_КМЭмитированы
	|				И (ЗаказНаЭмиссиюКодовМаркировкиСУЗ.Ссылка ЕСТЬ NULL
	|					ИЛИ ЗаказНаЭмиссиюКодовМаркировкиСУЗ.Ссылка.ПометкаУдаления)");
	Результат = Запрос.Выполнить();
	мПТУ = Результат.Выгрузить().ВыгрузитьКолонку("докПТУ");
	Возврат мПТУ;
КонецФункции

// Возвращаемое значение - <массив> - массив ссылок ДокументСсылка.ЗаказПоставщику
Функция ПолучитьСписокОбрабатываемыхЗаказовПоставщику()

	Запрос = Новый Запрос("ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ЗаказПоставщику.Ссылка КАК Заказ
	|ИЗ
	|	Документ.ЗаказПоставщику КАК ЗаказПоставщику
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК ЗаказНаЭмиссиюКодовМаркировкиСУЗ
	|		ПО ЗаказПоставщику.Ссылка = ЗаказНаЭмиссиюКодовМаркировкиСУЗ.ДокументОснование
	|ГДЕ
	|	ЗаказПоставщику.Проведен
	|	И ЗаказПоставщику.гф_ЗаказатьКМ
	|	И НЕ ЗаказПоставщику.гф_КМЭмитированы
	// vvv Галфинд \ Sakovich 29.03.2023
	//|	И ЗаказПоставщику.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыЗаказовПоставщикам.Согласован)
	|	И ЗаказПоставщику.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыЗаказовПоставщикам.Подтвержден)
	// ^^^ Галфинд \ Sakovich 29.03.2023
	|	И (ЗаказНаЭмиссиюКодовМаркировкиСУЗ.Ссылка ЕСТЬ NULL
	|			ИЛИ ЗаказНаЭмиссиюКодовМаркировкиСУЗ.Ссылка.ПометкаУдаления)");
	Результат = Запрос.Выполнить();
	мЗаказыПоставщику= Результат.Выгрузить().ВыгрузитьКолонку("Заказ");
	Возврат мЗаказыПоставщику;
	
КонецФункции

Процедура УстановитьСтатусыКМЭмитированыПТУ()
	мПТУ = ПолучитьПТУТребующиеУстановкиСтатусаКМЭмитированы();
	
	Запрос = Новый Запрос("ВЫБРАТЬ
    |	ПТУ.Ссылка КАК ПТУ,
    |	ЗаказКМ.Ссылка КАК ЗаказНаЭмиссию,
    |	тчТовары.Номенклатура КАК Номенклатура,
    |	тчТовары.Характеристика КАК Характеристика,
    |	СУММА(тчТовары.КоличествоУпаковок) КАК КоличествоУпаковок
    |ПОМЕСТИТЬ ДанныеПТУ
    |ИЗ
    |	Документ.ПриобретениеТоваровУслуг КАК ПТУ
    |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ПриобретениеТоваровУслуг.Товары КАК тчТовары
    |			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК спрНоменклатура
    |			ПО (тчТовары.Номенклатура = спрНоменклатура.Ссылка)
    |		ПО (ПТУ.Ссылка = тчТовары.Ссылка)
    |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК ЗаказКМ
    |		ПО (тчТовары.Ссылка = ЗаказКМ.ДокументОснование)
    |ГДЕ
    |	ПТУ.Ссылка В(&МассивПТУ)
    |	И спрНоменклатура.ОсобенностьУчета = ЗНАЧЕНИЕ(Перечисление.ОсобенностиУчетаНоменклатуры.ОбувнаяПродукция)
    |
    |СГРУППИРОВАТЬ ПО
    |	ПТУ.Ссылка,
    |	ЗаказКМ.Ссылка,
    |	тчТовары.Номенклатура,
    |	тчТовары.Характеристика
    |
    |ИНДЕКСИРОВАТЬ ПО
    |	ЗаказНаЭмиссию
    |;
    |
    |////////////////////////////////////////////////////////////////////////////////
    |ВЫБРАТЬ
    |	ДанныеПТУ.ПТУ КАК ПТУ,
    |	ДанныеПТУ.ЗаказНаЭмиссию КАК ЗаказНаЭмиссию
    |ПОМЕСТИТЬ ЗаказыНаЭмиссию
    |ИЗ
    |	ДанныеПТУ КАК ДанныеПТУ
    |
    |СГРУППИРОВАТЬ ПО
    |	ДанныеПТУ.ПТУ,
    |	ДанныеПТУ.ЗаказНаЭмиссию
    |;
    |
    |////////////////////////////////////////////////////////////////////////////////
    |ВЫБРАТЬ
    |	ЗаказыНаЭмиссию.ПТУ КАК ПТУ,
    |	ЗаказыНаЭмиссию.ЗаказНаЭмиссию КАК ЗаказНаЭмиссию,
    |	Пул.Номенклатура КАК Номенклатура,
    |	Пул.Характеристика КАК Характеристика,
    |	СУММА(1) КАК КоличествоУпаковок
    |ПОМЕСТИТЬ ДанныеПула
    |ИЗ
    |	ЗаказыНаЭмиссию КАК ЗаказыНаЭмиссию
    |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПулКодовМаркировкиСУЗ КАК Пул
    |		ПО ЗаказыНаЭмиссию.ЗаказНаЭмиссию = Пул.ЗаказНаЭмиссию
    |ГДЕ
    |	Пул.ЗаказНаЭмиссию ЕСТЬ НЕ NULL 
    |
    |СГРУППИРОВАТЬ ПО
    |	ЗаказыНаЭмиссию.ЗаказНаЭмиссию,
    |	Пул.Номенклатура,
    |	Пул.Характеристика,
    |	ЗаказыНаЭмиссию.ПТУ
    |;
    |
    |////////////////////////////////////////////////////////////////////////////////
    |ВЫБРАТЬ
    |	ДанныеПТУ.ПТУ КАК ПТУ,
    |	ДанныеПТУ.Номенклатура КАК Номенклатура,
    |	ДанныеПТУ.Характеристика КАК Характеристика,
    |	МАКСИМУМ(ДанныеПТУ.КоличествоУпаковок) КАК КоличествоУпаковок
    |ПОМЕСТИТЬ ДанныеПТУСвернуто
    |ИЗ
    |	ДанныеПТУ КАК ДанныеПТУ
    |
    |СГРУППИРОВАТЬ ПО
    |	ДанныеПТУ.ПТУ,
    |	ДанныеПТУ.Номенклатура,
    |	ДанныеПТУ.Характеристика
    |;
    |
    |////////////////////////////////////////////////////////////////////////////////
    |ВЫБРАТЬ
    |	ДанныеПула.ПТУ КАК ПТУ,
    |	ДанныеПула.Номенклатура КАК Номенклатура,
    |	ДанныеПула.Характеристика КАК Характеристика,
    |	СУММА(ДанныеПула.КоличествоУпаковок) КАК КоличествоУпаковок
    |ПОМЕСТИТЬ ДанныеПулаСвернуто
    |ИЗ
    |	ДанныеПула КАК ДанныеПула
    |
    |СГРУППИРОВАТЬ ПО
    |	ДанныеПула.Номенклатура,
    |	ДанныеПула.Характеристика,
    |	ДанныеПула.ПТУ
    |;
    |
    |////////////////////////////////////////////////////////////////////////////////
    |ВЫБРАТЬ
    |	ДанныеПТУСвернуто.ПТУ КАК ПТУ,
    |	ДанныеПТУСвернуто.Номенклатура КАК Номенклатура,
    |	ДанныеПТУСвернуто.Характеристика КАК Характеристика,
    |	ВЫБОР
    |		КОГДА ДанныеПТУСвернуто.КоличествоУпаковок = ЕСТЬNULL(ДанныеПулаСвернуто.КоличествоУпаковок, 0)
    |			ТОГДА ИСТИНА
    |		ИНАЧЕ ЛОЖЬ
    |	КОНЕЦ КАК КоличествоКМСовпадает
    |ПОМЕСТИТЬ ДанныеСравнения
    |ИЗ
    |	ДанныеПТУСвернуто КАК ДанныеПТУСвернуто
    |		ЛЕВОЕ СОЕДИНЕНИЕ ДанныеПулаСвернуто КАК ДанныеПулаСвернуто
    |		ПО (ДанныеПТУСвернуто.ПТУ = ДанныеПулаСвернуто.ПТУ
    |				И ДанныеПТУСвернуто.Номенклатура = ДанныеПулаСвернуто.Номенклатура
    |				И ДанныеПТУСвернуто.Характеристика = ДанныеПулаСвернуто.Характеристика)
    |;
    |
    |////////////////////////////////////////////////////////////////////////////////
    |ВЫБРАТЬ
    |	ДанныеСравнения.ПТУ КАК ПТУ,
    |	МИНИМУМ(ДанныеСравнения.КоличествоКМСовпадает) КАК КоличествоКМСовпадает
    |ИЗ
    |	ДанныеСравнения КАК ДанныеСравнения
    |
    |СГРУППИРОВАТЬ ПО
    |	ДанныеСравнения.ПТУ
    |
    |ИМЕЮЩИЕ
    |	МИНИМУМ(ДанныеСравнения.КоличествоКМСовпадает) = ИСТИНА");
	
	Запрос.УстановитьПараметр("МассивПТУ", мПТУ);
	Результат = Запрос.Выполнить();
	
	мПТУ_КМЭмитированы = Новый Массив;
	
	Если Не Результат.Пустой() Тогда
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() Цикл
			обПТУ = Выборка["ПТУ"].ПолучитьОбъект();
			Если обПТУ <> Неопределено Тогда
				обПТУ.гф_КМЭмитированы = Истина;
				Попытка
					обПТУ.Записать();
					мПТУ_КМЭмитированы.Добавить(обПТУ.Ссылка);
				Исключение
					ЗаписьЖурналаРегистрации("РегламентноеЗадание.гф_СозданиеДокументовЭмиссииКМ.ОшибкаУстановкаСтатусовКМЭмитированы",
					УровеньЖурналаРегистрации.Информация, 
					Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ);
					
					ТекстОшибки = ОписаниеОшибки();
					СтрокаСообщения = "Ошибка при установке статуса ""КМм эмитированы"" в документе " + Выборка["ПТУ"] + ":  " + ТекстОшибки;
					
					ЗаписьЖурналаРегистрации("ОбработкаЗаказовНаЭмиссиюКМ.ОшибкаПриУстановкеСтатусаКМЭмитированы", 
					УровеньЖурналаРегистрации.Информация, 
					Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ, ,
					СтрокаСообщения);
					Продолжить;
				КонецПопытки;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	// vvv Галфинд \ Sakovich 08.06.2023
	// создание штрихкодов производится рег.заданием гф_ГенерацияЭлементовМаркированныйТовар
	// см. гф_ЭмиссияКодовМаркировкиВызовСервера.ПроверитьСоздатьЭлементыМаркированныйТовар()

	//ПроверитьСоздатьЭлементыШтрихкодыУпаковокТоваров(мПТУ_КМЭмитированы);
	// ^^^ Галфинд \ Sakovich 08.06.2023 
	
	ОбработатьУпаковочныеЛисты(мПТУ_КМЭмитированы);
	СоздатьЗаполнитьОрдераПоПТУ(мПТУ_КМЭмитированы);
КонецПроцедуры

Процедура УстановитьСтатусыКМЭмитированыЗаказыПоставщикам()
	
	// ++ Галфинд_ДомнышеваКР_07_06_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
	//мЗаказов = ПолучитьСписокОбрабатываемыхЗаказовПоставщику();
	мЗаказов =  ПолучитьСписокЭммитированныхЗаказовПоставщику();
	// -- Галфинд_ДомнышеваКР_07_06_2023
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	Заказы.Ссылка КАК Заказ,
	|	ЗаказКМ.Ссылка КАК ЗаказНаЭмиссию,
	|	тчТовары.Номенклатура КАК Номенклатура,
	|	тчТовары.Характеристика КАК Характеристика,
	|	СУММА(тчТовары.КоличествоУпаковок) КАК КоличествоУпаковок
	|ПОМЕСТИТЬ ДанныеЗаказов
	|ИЗ
	|	Документ.ЗаказПоставщику КАК Заказы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказПоставщику.Товары КАК тчТовары
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК спрНоменклатура
	|			ПО тчТовары.Номенклатура = спрНоменклатура.Ссылка
	|		ПО Заказы.Ссылка = тчТовары.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК ЗаказКМ
	|		ПО (тчТовары.Ссылка = ЗаказКМ.ДокументОснование)
	|ГДЕ
	|	Заказы.Ссылка В(&МассивЗаказов)
	|	И спрНоменклатура.ОсобенностьУчета = ЗНАЧЕНИЕ(Перечисление.ОсобенностиУчетаНоменклатуры.ОбувнаяПродукция)
	|
	|СГРУППИРОВАТЬ ПО
	|	Заказы.Ссылка,
	|	ЗаказКМ.Ссылка,
	|	тчТовары.Номенклатура,
	|	тчТовары.Характеристика
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ЗаказНаЭмиссию
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеЗаказов.Заказ КАК Заказ,
	|	ДанныеЗаказов.ЗаказНаЭмиссию КАК ЗаказНаЭмиссию
	|ПОМЕСТИТЬ ЗаказыНаЭмиссию
	|ИЗ
	|	ДанныеЗаказов КАК ДанныеЗаказов
	|
	|СГРУППИРОВАТЬ ПО
	|	ДанныеЗаказов.Заказ,
	|	ДанныеЗаказов.ЗаказНаЭмиссию
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗаказыНаЭмиссию.Заказ КАК Заказ,
	|	ЗаказыНаЭмиссию.ЗаказНаЭмиссию КАК ЗаказНаЭмиссию,
	|	Пул.Номенклатура КАК Номенклатура,
	|	Пул.Характеристика КАК Характеристика,
	|	СУММА(1) КАК КоличествоУпаковок
	|ПОМЕСТИТЬ ДанныеПула
	|ИЗ
	|	ЗаказыНаЭмиссию КАК ЗаказыНаЭмиссию
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПулКодовМаркировкиСУЗ КАК Пул
	|		ПО ЗаказыНаЭмиссию.ЗаказНаЭмиссию = Пул.ЗаказНаЭмиссию
	|ГДЕ
	|	Пул.ЗаказНаЭмиссию ЕСТЬ НЕ NULL 
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗаказыНаЭмиссию.ЗаказНаЭмиссию,
	|	Пул.Номенклатура,
	|	Пул.Характеристика,
	|	ЗаказыНаЭмиссию.Заказ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеЗаказов.Заказ КАК Заказ,
	|	ДанныеЗаказов.Номенклатура КАК Номенклатура,
	|	ДанныеЗаказов.Характеристика КАК Характеристика,
	|	МАКСИМУМ(ДанныеЗаказов.КоличествоУпаковок) КАК КоличествоУпаковок
	|ПОМЕСТИТЬ ДанныеЗаказовСвернуто
	|ИЗ
	|	ДанныеЗаказов КАК ДанныеЗаказов
	|
	|СГРУППИРОВАТЬ ПО
	|	ДанныеЗаказов.Заказ,
	|	ДанныеЗаказов.Номенклатура,
	|	ДанныеЗаказов.Характеристика
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеПула.Заказ КАК Заказ,
	|	ДанныеПула.Номенклатура КАК Номенклатура,
	|	ДанныеПула.Характеристика КАК Характеристика,
	|	СУММА(ДанныеПула.КоличествоУпаковок) КАК КоличествоУпаковок
	|ПОМЕСТИТЬ ДанныеПулаСвернуто
	|ИЗ
	|	ДанныеПула КАК ДанныеПула
	|
	|СГРУППИРОВАТЬ ПО
	|	ДанныеПула.Номенклатура,
	|	ДанныеПула.Характеристика,
	|	ДанныеПула.Заказ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеЗаказовСвернуто.Заказ КАК Заказ,
	|	ДанныеЗаказовСвернуто.Номенклатура КАК Номенклатура,
	|	ДанныеЗаказовСвернуто.Характеристика КАК Характеристика,
	|	ВЫБОР
	|		КОГДА ДанныеЗаказовСвернуто.КоличествоУпаковок = ЕСТЬNULL(ДанныеПулаСвернуто.КоличествоУпаковок, 0)
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК КоличествоКМСовпадает
	|ПОМЕСТИТЬ ДанныеСравнения
	|ИЗ
	|	ДанныеЗаказовСвернуто КАК ДанныеЗаказовСвернуто
	|		ЛЕВОЕ СОЕДИНЕНИЕ ДанныеПулаСвернуто КАК ДанныеПулаСвернуто
	|		ПО ДанныеЗаказовСвернуто.Заказ = ДанныеПулаСвернуто.Заказ
	|			И ДанныеЗаказовСвернуто.Номенклатура = ДанныеПулаСвернуто.Номенклатура
	|			И ДанныеЗаказовСвернуто.Характеристика = ДанныеПулаСвернуто.Характеристика
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеСравнения.Заказ КАК Заказ,
	|	МИНИМУМ(ДанныеСравнения.КоличествоКМСовпадает) КАК КоличествоКМСовпадает
	|ИЗ
	|	ДанныеСравнения КАК ДанныеСравнения
	|
	|СГРУППИРОВАТЬ ПО
	|	ДанныеСравнения.Заказ
	|
	|ИМЕЮЩИЕ
	|	МИНИМУМ(ДанныеСравнения.КоличествоКМСовпадает) = ИСТИНА");
	
	Запрос.УстановитьПараметр("МассивЗаказов", мЗаказов);
	Результат = Запрос.Выполнить();
	
	мЗаказы_КМЭмитированы = Новый Массив;
	
	Если Не Результат.Пустой() Тогда
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() Цикл
			обЗаказ = Выборка["Заказ"].ПолучитьОбъект();
			Если обЗаказ <> Неопределено Тогда
				обЗаказ.гф_КМЭмитированы = Истина;
				Попытка
					обЗаказ.Записать();
					мЗаказы_КМЭмитированы.Добавить(обЗаказ.Ссылка);
				Исключение
					ЗаписьЖурналаРегистрации("РегламентноеЗадание.гф_СозданиеДокументовЭмиссииКМ.ОшибкаУстановкаСтатусовКМЭмитированы",
					УровеньЖурналаРегистрации.Информация, 
					Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ);
					
					ТекстОшибки = ОписаниеОшибки();
					СтрокаСообщения = "Ошибка при установке статуса ""КМм эмитированы"" в документе " + Выборка["Заказ"] + ":  " + ТекстОшибки;
					
					ЗаписьЖурналаРегистрации("ОбработкаЗаказовНаЭмиссиюКМ.ОшибкаПриУстановкеСтатусаКМЭмитированы", 
					УровеньЖурналаРегистрации.Информация, 
					Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ, ,
					СтрокаСообщения);
					Продолжить;
				КонецПопытки;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	ПроверитьСоздатьЭлементыШтрихкодыУпаковокТоваров(мЗаказы_КМЭмитированы);
	ОбработатьУпаковочныеЛисты(мЗаказы_КМЭмитированы);
	
КонецПроцедуры

Процедура ПроверитьУстановитьСтатусыКМЭмитированы() Экспорт
	УстановитьСтатусыКМЭмитированыПТУ();
	УстановитьСтатусыКМЭмитированыЗаказыПоставщикам();
	// vvv Галфинд \ Sakovich 03.04.2023
	ДополнительноОбработатьУЛПоДокументамСПризнакомКМЭмитированы();
	// ^^^ Галфинд \ Sakovich 03.04.2023 
КонецПроцедуры

Процедура ОбработатьУпаковочныеЛисты(мДокументов)
	
	соотвУл = ПолучитьМассивУЛизДокументов(мДокументов);
	Для каждого КлючЗначение Из соотвУл Цикл
		МассивУЛ = КлючЗначение.Значение;
		Для каждого ЭлУЛ Из МассивУЛ Цикл
			
			// vvv Галфинд \ Sakovich 03.04.2023
			Если (ЭлУЛ.Проведен 
				И Не ЭлУЛ["гф_Агрегация"] = Справочники.ШтрихкодыУпаковокТоваров.ПустаяСсылка()) Тогда
				Продолжить;
			КонецЕсли;
			Если ЭлУЛ.ПометкаУдаления Тогда
				Продолжить;
			КонецЕсли;
			// ^^^ Галфинд \ Sakovich 03.04.2023
			
			обУл = ЭлУЛ.ПолучитьОбъект();
			Если обУл <> Неопределено Тогда
				Попытка
					обУл.Записать(РежимЗаписиДокумента.Проведение);
				Исключение
					ТекстОшибки = ОписаниеОшибки();
					СтрокаСообщения = "Ошибка при проведении документа ""Упаковочный лист"": " + обУл.Ссылка+ "  " + ТекстОшибки;
					ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовЭмиссииКМ.ОшибкаПриУстановкеСтатусовКМЭтитированы",
					УровеньЖурналаРегистрации.Информация, 
					Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ, ,СтрокаСообщения);
				КонецПопытки;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

Процедура ДополнительноОбработатьУЛПоДокументамСПризнакомКМЭмитированы() 
	
	// vvv Галфинд \ Sakovich 03.04.2023
	//дополнительно обработаем УЛ из Поставок и заказов с признаком "КМ Эмитированы", в которых не проставлена агрегация
	Запрос = Новый Запрос;
	Запрос.Текст ="
	|ВЫБРАТЬ
	|	ПТУ.Ссылка КАК ПТУ
	|ПОМЕСТИТЬ ПТУ_КМЭмитированы
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг КАК ПТУ
	|ГДЕ
	|	ПТУ.Проведен
	|	И ПТУ.гф_ЗаказатьКМ
	|	И ПТУ.гф_КМЭмитированы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Заказ.Ссылка КАК Заказ
	|ПОМЕСТИТЬ Заказы_КМЭмитированы
	|ИЗ
	|	Документ.ЗаказПоставщику КАК Заказ
	|ГДЕ
	|	Заказ.Проведен
	|	И Заказ.гф_ЗаказатьКМ
	|	И Заказ.гф_КМЭмитированы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	докУЛ.Ссылка КАК докУЛСсылка
	|ПОМЕСТИТЬ докУЛ
	|ИЗ
	|	Документ.УпаковочныйЛист КАК докУЛ
	|ГДЕ  
	|   НЕ докУЛ.ПометкаУдаления
	|	И НЕ докУЛ.Проведен
	|	И докУЛ.гф_Агрегация = ЗНАЧЕНИЕ(Справочник.ШтрихкодыУпаковокТоваров.ПустаяСсылка)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТоварыВКоробах.IDКороба КАК УЛ,
	|	ТоварыВКоробах.Ссылка КАК Документ
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг.гф_ПродукцияВКоробах КАК ТоварыВКоробах
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПТУ_КМЭмитированы КАК ПТУ_КМЭмитированы
	|		ПО (ПТУ_КМЭмитированы.ПТУ = ТоварыВКоробах.Ссылка)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ докУЛ КАК докУЛ
	|		ПО ТоварыВКоробах.IDКороба = докУЛ.докУЛСсылка
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ТоварыВКоробах.IDКороба,
	|	ТоварыВКоробах.Ссылка
	|ИЗ
	|	Документ.ЗаказПоставщику.гф_ПродукцияВКоробах КАК ТоварыВКоробах
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Заказы_КМЭмитированы КАК Заказы_КМЭмитированы
	|		ПО (Заказы_КМЭмитированы.Заказ = ТоварыВКоробах.Ссылка)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ докУЛ КАК докУЛ
	|		ПО ТоварыВКоробах.IDКороба = докУЛ.докУЛСсылка";
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		обУл = Выборка["УЛ"].ПолучитьОбъект();
		Если обУл <> Неопределено Тогда
			Попытка
				обУл.Записать(РежимЗаписиДокумента.Проведение);
			Исключение
				ТекстОшибки = ОписаниеОшибки();
				СтрокаСообщения = "Ошибка при проведении документа ""Упаковочный лист"": " + обУл.Ссылка+ "  " + ТекстОшибки;
				ЗаписьЖурналаРегистрации("РегламентноеСозданиеДокументовЭмиссииКМ.ОшибкаПриУстановкеСтатусовКМЭтитированы",
				УровеньЖурналаРегистрации.Информация, 
				Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ, ,СтрокаСообщения);
			КонецПопытки;
		КонецЕсли;
	КонецЦикла
	// ^^^ Галфинд \ Sakovich 03.04.2023 
	
КонецПроцедуры

Процедура СоздатьЗаполнитьОрдераПоПТУ(мПТУ)

	соотвУлПТУ = ПолучитьМассивУЛизДокументов(мПТУ);
	Для каждого КлючЗначение Из соотвУлПТУ Цикл
		Основание = КлючЗначение.Ключ;
		
		ЕстьОрдерПоДанномуОснованию = ПроверитьНаличиеОрдераПоОснованию(Основание);
		Если ЕстьОрдерПоДанномуОснованию Тогда
			Продолжить;
		КонецЕсли;
		
		МассивУЛ = КлючЗначение.Значение;
		СтруктураПолейЗаполнения = Новый Структура();
		СтруктураПолейЗаполнения.Вставить("Склад");
		СтруктураПолейЗаполнения.Вставить("Распоряжение", "Ссылка");
		СтруктураПолейЗаполнения.Вставить("ДатаПоступления");
		СтруктураПолейЗаполнения.Вставить("Отправитель", "Партнер");
		СтруктураПолейЗаполнения.Вставить("ДатаВходящегоДокумента");
		СтруктураПолейЗаполнения.Вставить("НомерВходящегоДокумента");
		СтруктураПолейЗаполнения.Вставить("ХозяйственнаяОперация");
		
		СтруктРеквизитов = Новый ФиксированнаяСтруктура(СтруктураПолейЗаполнения);
		ЗначенияРеквизитовОснования = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Основание, СтруктРеквизитов);
		
		ДанныеЗаполнения = Новый Структура(
		"Склад, Помещение, Распоряжение, ДатаПоступления, ЗонаПриемки, СкладскаяОперация, " + 
		"Отправитель, ДатаВходящегоДокумента, НомерВходящегоДокумента, ХозяйственнаяОперация");
		ЗаполнитьЗначенияСвойств(ДанныеЗаполнения, ЗначенияРеквизитовОснования);
		ДанныеЗаполнения["СкладскаяОперация"] = Перечисления.СкладскиеОперации.ПриемкаОтПоставщика;
		
		обПрОрдер = Документы.ПриходныйОрдерНаТовары.СоздатьДокумент();
		обПрОрдер["Дата"] = ТекущаяДатаСеанса();
		обПрОрдер.Заполнить(ДанныеЗаполнения);
		обПрОрдер["Ответственный"] = Пользователи.АвторизованныйПользователь();
		обПрОрдер["Статус"] = Перечисления.СтатусыПриходныхОрдеров.КПоступлению;
		
		ЗаполнитьШтрихкодыОрдера(обПрОрдер, Основание);

		обПрОрдер.Записать(РежимЗаписиДокумента.Проведение);
	КонецЦикла;
	
КонецПроцедуры

Функция ПроверитьНаличиеОрдераПоОснованию(Основание)
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	ПриходныйОрдерНаТовары.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.ПриходныйОрдерНаТовары КАК ПриходныйОрдерНаТовары
	|ГДЕ
	|	ПриходныйОрдерНаТовары.Распоряжение = &Основание
	|	И НЕ ПриходныйОрдерНаТовары.ПометкаУдаления");
	Запрос.УстановитьПараметр("Основание",Основание);
	Результат = Запрос.Выполнить();
	Возврат Не Результат.Пустой();
	
КонецФункции 


Процедура ЗаполнитьШтрихкодыОрдера(ОбъектОрдер, Основание)
	
	СкладПолучательКоробочный = 
	УправлениеСвойствами.ЗначениеСвойства(ОбъектОрдер["Склад"], "гф_СкладыТоварыВКоробах") = Истина;
	
	Запрос = Новый Запрос;
	Если СкладПолучательКоробочный Тогда
		// заполняем Агрегатами кодов маркировки
		лТовары = ОбъектОрдер.Товары.Выгрузить();
		
		Запрос.Текст ="ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	т.УпаковочныйЛист КАК УпаковочныйЛист,
		|	т.ЭтоУпаковочныйЛист
		|ПОМЕСТИТЬ УпЛисты
		|ИЗ
		|	&Товары КАК т
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ШтрихкодыУпаковокТоваров.Ссылка КАК ШтрихкодУпаковки
		|ИЗ
		|	УпЛисты КАК УпЛисты
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
		|		ПО УпЛисты.УпаковочныйЛист.Код = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода
		|ГДЕ
		|	УпЛисты.ЭтоУпаковочныйЛист
		|	И ШтрихкодыУпаковокТоваров.Ссылка ЕСТЬ НЕ NULL 
		|	И ШтрихкодыУпаковокТоваров.ТипУпаковки = ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МультитоварнаяУпаковка)";
		Запрос.УстановитьПараметр("Товары", лТовары);
		
		Результат = Запрос.Выполнить();
	Иначе	
		Запрос.Текст = "ВЫБРАТЬ
		|	Пул.КодМаркировки КАК КодМаркировки,
		|	Пул.Номенклатура КАК Номенклатура,
		|	Пул.Характеристика КАК Характеристика
		|ПОМЕСТИТЬ ПулКодов
		|ИЗ
		|	Документ.ПриобретениеТоваровУслуг КАК ПТУ
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК докЭмиссия
		|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПулКодовМаркировкиСУЗ КАК Пул
		|			ПО докЭмиссия.Ссылка = Пул.ЗаказНаЭмиссию
		|		ПО ПТУ.Ссылка = докЭмиссия.ДокументОснование
		|ГДЕ
		|	ПТУ.Ссылка = &Основание 
		|	И докЭмиссия.Ссылка ЕСТЬ НЕ NULL 
		|	И Пул.ЗаказНаЭмиссию ЕСТЬ НЕ NULL 
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Пул.КодМаркировки,
		|	Номенклатура,
		|	Характеристика
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ШтрихкодыУпаковокТоваров.Ссылка КАК ШтрихкодУпаковки
		|ИЗ
		|	ПулКодов КАК ПулКодов
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
		|		ПО ПулКодов.КодМаркировки = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода
		|			И ПулКодов.Номенклатура = ШтрихкодыУпаковокТоваров.Номенклатура
		|			И ПулКодов.Характеристика = ШтрихкодыУпаковокТоваров.Характеристика
		|ГДЕ
		|	ШтрихкодыУпаковокТоваров.ТипУпаковки = ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МаркированныйТовар)
		|	И ШтрихкодыУпаковокТоваров.Ссылка ЕСТЬ НЕ NULL";
		
		Запрос.УстановитьПараметр("Основание", Основание);
		Результат = Запрос.Выполнить();
	КонецЕсли;
	
	Если Результат.Пустой() Тогда
		Возврат;	
	КонецЕсли;
	
	тзШтрихкоды = Результат.Выгрузить();
	ОбъектОрдер.ШтрихкодыУпаковок.Загрузить(тзШтрихкоды);
	
КонецПроцедуры

// Получает массивы упаковочных листов для переданного массива документов
// Параметры:
//		мДокументов - Массив - массив ссылок на документы "ПриобретениеТоваровУслуг", "ЗаказПоставщику"
// Возвращаемое значение:
//		Соответствие - , ключ - ссылка на документ, значение - массив ссылок на документ "УпаковочныйЛист"
Функция ПолучитьМассивУЛизДокументов(мДокументов)
	соотвУл = Новый Соответствие;
	Для каждого Эл Из мДокументов Цикл
		МассивУЛ = Эл.гф_ПродукцияВКоробах.ВыгрузитьКолонку("IDКороба");
		соотвУл.Вставить(Эл, МассивУЛ);
	КонецЦикла;
	Возврат соотвУл;
КонецФункции


Процедура ПроверитьСоздатьЭлементыШтрихкодыУпаковокТоваров(мДокументов)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	т.Ссылка КАК Док
	|ПОМЕСТИТЬ Документы
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг КАК т
	|ГДЕ
	|	т.Ссылка В(&мДокументов)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	т.Ссылка
	|ИЗ
	|	Документ.ЗаказПоставщику КАК т
	|ГДЕ
	|	т.Ссылка В(&мДокументов)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Документы.Док КАК Док,
	|	докЭмиссия.Ссылка КАК Ссылка,
	|	Пул.ЗаказНаЭмиссию КАК ЗаказНаЭмиссию,
	|	Пул.КодМаркировки КАК КодМаркировки,
	|	Пул.Номенклатура КАК Номенклатура,
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee224d0352ee32 
	// Галфинд_Домнышева 2023/07/18
	|	Пул.ДокументОснование КАК ДокументОснование,
	|	Пул.ПолныйКодМаркировки КАК ПолныйКодМаркировки,
	// } #wortmann
	|	Пул.Характеристика КАК Характеристика
	|ПОМЕСТИТЬ ПулКодов
	|ИЗ
	|	Документы КАК Документы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК докЭмиссия
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПулКодовМаркировкиСУЗ КАК Пул
	|			ПО докЭмиссия.Ссылка = Пул.ЗаказНаЭмиссию
	|		ПО Документы.Док = докЭмиссия.ДокументОснование
	|ГДЕ
	|	докЭмиссия.Ссылка ЕСТЬ НЕ NULL 
	|	И Пул.ЗаказНаЭмиссию ЕСТЬ НЕ NULL 
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Пул.КодМаркировки,
	|	Номенклатура,
	|	Характеристика
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МаркированныйТовар) КАК ТипУпаковки,
	|	ЗНАЧЕНИЕ(Перечисление.ТипыШтрихкодов.GS1_DataMatrix) КАК ТипШтрихкода,
	|	1 КАК Количество,
	|	ПулКодов.КодМаркировки КАК ЗначениеШтрихкода,
	|	ПулКодов.Номенклатура КАК Номенклатура,
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee224d0352ee32 
	// Галфинд_Домнышева 2023/07/18
	|	ПулКодов.ДокументОснование КАК гф_ДокументОснование,
	|	ПулКодов.ПолныйКодМаркировки КАК гф_ПолныйКодМаркировки,
	// } #wortmann
	// vvv Галфинд \ Sakovich 20.07.2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0441749bccbe
	|	ПулКодов.ЗаказНаЭмиссию КАК ЗаказНаЭмиссию,
	// ^^^ Галфинд \ Sakovich 20.07.2023
	|	ПулКодов.Характеристика КАК Характеристика
	|ИЗ
	|	ПулКодов КАК ПулКодов
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|		ПО ПулКодов.КодМаркировки = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода
	|			И ПулКодов.Номенклатура = ШтрихкодыУпаковокТоваров.Номенклатура
	|			И ПулКодов.Характеристика = ШтрихкодыУпаковокТоваров.Характеристика
	|			И (ШтрихкодыУпаковокТоваров.ТипУпаковки = ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МаркированныйТовар))
	|ГДЕ
	|	ШтрихкодыУпаковокТоваров.Ссылка ЕСТЬ NULL";
	
	Запрос.УстановитьПараметр("мДокументов", мДокументов);
	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		обШК = Справочники.ШтрихкодыУпаковокТоваров.СоздатьЭлемент();
		ЗаполнитьЗначенияСвойств(обШК, Выборка);
		// vvv Галфинд \ Sakovich 20.07.2023
		СтатусЭмитирован = Перечисления.гф_СтатусыКМ_в_ШК.Эмитирован;
		обШК.гф_Статус = СтатусЭмитирован;
		КМЗаписан = Истина;
		// ^^^ Галфинд \ Sakovich 20.07.2023
		Попытка
			обШК.Записать();
		Исключение
			КМЗаписан = Ложь; //Добавлено  Галфинд \ Sakovich 20.07.2023
			ТекстОшибки = ОписаниеОшибки();
			СтрокаСообщения = "Не удалось записать элемент справочника ""Штрихкоды упаковок товары""
			|со значением штрихкода "+ Выборка["ЗначениеШтрихкода"] +" Ошибка: " + ТекстОшибки;
			
			ЗаписьЖурналаРегистрации("Справочник.ШтрихкодыУпаковокТоваров.ОшибкаЗаписи", 
			УровеньЖурналаРегистрации.Информация, 
			Метаданные.Обработки.гф_ОбработкаЗаказовНаЭмиссиюКМ, ,
			СтрокаСообщения);
		КонецПопытки;
		// vvv Галфинд \ Sakovich 20.07.2023
		Если КМЗаписан Тогда
			Период = ТекущаяДатаСеанса();
			гф_ЭмиссияКодовМаркировкиВызовСервера.ЗаписатьИсторияСтатусовКМ(Период, обШК.Ссылка, СтатусЭмитирован, Выборка["ЗаказНаЭмиссию"]);
		КонецЕсли;
		// ^^^ Галфинд \ Sakovich 20.07.2023
	КонецЦикла;
	
КонецПроцедуры


Функция ПолучитьПТУТребующиеУстановкиСтатусаКМЭмитированы() Экспорт
	Запрос = Новый Запрос("ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПриобретениеТоваровУслуг.Ссылка КАК докПТУ
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг КАК ПриобретениеТоваровУслуг
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК ЗаказНаЭмиссиюКодовМаркировкиСУЗ
	|		ПО (ПриобретениеТоваровУслуг.Ссылка = ЗаказНаЭмиссиюКодовМаркировкиСУЗ.ДокументОснование)
	|ГДЕ
	|	НЕ ПриобретениеТоваровУслуг.гф_КМЭмитированы    
	|	И  ПриобретениеТоваровУслуг.Проведен
	|	И ЗаказНаЭмиссиюКодовМаркировкиСУЗ.Ссылка ЕСТЬ НЕ NULL");
	Результат = Запрос.Выполнить();
	мПТУ = Результат.Выгрузить().ВыгрузитьКолонку("ДокПТУ");
	Возврат мПТУ;
КонецФункции 

// Возвращаемое значение - <массив> - массив ссылок ДокументСсылка.ЗаказПоставщику
Функция ПолучитьСписокЭммитированныхЗаказовПоставщику()

	Запрос = Новый Запрос("ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ЗаказПоставщику.Ссылка КАК Заказ
	|ИЗ
	|	Документ.ЗаказПоставщику КАК ЗаказПоставщику
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ КАК ЗаказНаЭмиссиюКодовМаркировкиСУЗ
	|        Левое соединение РегистрСведений.СтатусыДокументовИСМП КАК Статусы
	|		    ПО ЗаказНаЭмиссиюКодовМаркировкиСУЗ.ссылка = Статусы.Документ
	|		ПО ЗаказПоставщику.Ссылка = ЗаказНаЭмиссиюКодовМаркировкиСУЗ.ДокументОснование
	|ГДЕ
	|	ЗаказПоставщику.Проведен
	|	И ЗаказПоставщику.гф_ЗаказатьКМ
	|	И НЕ ЗаказПоставщику.гф_КМЭмитированы
	|	И (ЗаказНаЭмиссиюКодовМаркировкиСУЗ.Ссылка ЕСТЬ НЕ NULL 
	|	И НЕ ЗаказНаЭмиссиюКодовМаркировкиСУЗ.Ссылка.ПометкаУдаления
	|	И Статусы.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыОбработкиЗаказовНаЭмиссиюКодовМаркировкиИСМП.СУЗКодыМаркировкиЭмитированы))");
	Результат = Запрос.Выполнить();
	мЗаказыПоставщику= Результат.Выгрузить().ВыгрузитьКолонку("Заказ");
	Возврат мЗаказыПоставщику;
	
КонецФункции

#КонецОбласти
	
#КонецЕсли