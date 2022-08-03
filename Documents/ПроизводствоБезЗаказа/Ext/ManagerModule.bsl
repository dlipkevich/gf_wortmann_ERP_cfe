﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// #wortmann {
// #5.2.04
// стандартные подсистемы. Загрузка из внешнего файла
// Галфинд Sakovich 2022/08/02
//
// Параметры:
//   Параметры - Структура - переопределяемые параметры (необходимо, 
//                  если поддерживается загрузка в несколько табличных частей).
Процедура УстановитьПараметрыЗагрузкиИзФайлаВТЧ(Параметры) Экспорт
	Если Параметры["ИмяТабличнойЧасти"] = "Документ.ПроизводствоБезЗаказа.ТабличнаяЧасть.ВыходныеИзделия" Тогда
		Параметры["ИмяМакетаСШаблоном"] = "ЗагрузкаИзФайлаВыходныеИзделия";
	КонецЕсли;
КонецПроцедуры // } #wortmann


// #wortmann {
// #5.2.04
// прикладной алгоритм поиска данных в ИБ по данным, загруженным из файла
// Галфинд Sakovich 2022/08/02
// Производит сопоставление данных, загружаемых в табличную часть ПолноеИмяТабличнойЧасти,
// с данными в ИБ, и заполняет параметры АдресТаблицыСопоставления и СписокНеоднозначностей.
// СписокНеоднозначностей содержит список неоднозначных значений, для которых в ИБ имеется несколько
// подходящих вариантов.
//
// Параметры:
//   АдресЗагружаемыхДанных    - Строка - адрес временного хранилища с таблицей значений, в которой
//                                        находятся загруженные данные из файла. Состав колонок:
//     * Идентификатор - Число - порядковый номер строки.
//       Остальные колонки соответствуют колонкам макета ЗагрузкаИзФайла.
//   АдресТаблицыСопоставления - Строка - адрес временного хранилища с пустой таблицей значений,
//                                        являющейся копией табличной части документа, 
//                                        которую необходимо заполнить из таблицы АдресЗагружаемыхДанных.
//   СписокНеоднозначностей - ТаблицаЗначений - список неоднозначных значений:
//     * Колонка       - Строка - имя колонки, в которой была обнаружена неоднозначность.
//     * Идентификатор - Число - идентификатор строки, в которой была обнаружена неоднозначность.
//   ПолноеИмяТабличнойЧасти   - Строка - полное имя табличной части, в которую загружаются данные.
//   ДополнительныеПараметры   - Произвольный - любые дополнительные сведения.
//
Процедура СопоставитьЗагружаемыеДанные(АдресЗагружаемыхДанных, 
	АдресТаблицыСопоставления, 
	СписокНеоднозначностей, 
	ПолноеИмяТабличнойЧасти, 
	ДополнительныеПараметры) Экспорт

	Товары = ПолучитьИзВременногоХранилища(АдресТаблицыСопоставления); // ТаблицаЗначений
	ЗагружаемыеДанные = ПолучитьИзВременногоХранилища(АдресЗагружаемыхДанных); // ТаблицаЗначений
	
	МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВЫРАЗИТЬ(ДанныеДляСопоставления.Артикул КАК СТРОКА(50)) КАК Артикул,
		|	ДанныеДляСопоставления.Номенклатура КАК Номенклатура,
		|	ДанныеДляСопоставления.Идентификатор КАК Идентификатор
		|ПОМЕСТИТЬ ДанныеДляСопоставления
		|ИЗ
		|	&ДанныеДляСопоставления КАК ДанныеДляСопоставления
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СпрНоменклатура.Ссылка КАК Ссылка,
		|	СпрНоменклатура.Артикул КАК Артикул,
		|	ДанныеДляСопоставления.Идентификатор КАК Идентификатор
		|ПОМЕСТИТЬ СопоставленнаяНоменклатураПоАртикулу
		|ИЗ
		|	ДанныеДляСопоставления КАК ДанныеДляСопоставления
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК СпрНоменклатура
		|		ПО (СпрНоменклатура.Артикул = ДанныеДляСопоставления.Артикул)
		|			И (ДанныеДляСопоставления.Артикул <> """")
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Идентификатор
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДанныеДляСопоставления.Номенклатура КАК Номенклатура,
		|	ДанныеДляСопоставления.Идентификатор КАК Идентификатор
		|ПОМЕСТИТЬ ДанныеДляСопоставленияПоНаименованию
		|ИЗ
		|	ДанныеДляСопоставления КАК ДанныеДляСопоставления
		|		ЛЕВОЕ СОЕДИНЕНИЕ СопоставленнаяНоменклатураПоАртикулу КАК СопоставленнаяНоменклатураПоАртикулу
		|		ПО ДанныеДляСопоставления.Идентификатор = СопоставленнаяНоменклатураПоАртикулу.Идентификатор
		|ГДЕ СопоставленнаяНоменклатураПоАртикулу.Идентификатор ЕСТЬ NULL
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Идентификатор
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	МАКСИМУМ(СпрНоменклатура.Ссылка) КАК Ссылка,
		|	ДанныеДляСопоставленияПоНаименованию.Идентификатор КАК Идентификатор,
		|	КОЛИЧЕСТВО(ДанныеДляСопоставленияПоНаименованию.Идентификатор) КАК Количество
		|ИЗ
		|	ДанныеДляСопоставленияПоНаименованию КАК ДанныеДляСопоставленияПоНаименованию
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК СпрНоменклатура
		|		ПО (СпрНоменклатура.Наименование = (ВЫРАЗИТЬ(ДанныеДляСопоставленияПоНаименованию.Номенклатура КАК СТРОКА(500))))
		|
		|СГРУППИРОВАТЬ ПО
		|	ДанныеДляСопоставленияПоНаименованию.Идентификатор
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	МАКСИМУМ(СопоставленнаяНоменклатураПоАртикулу.Ссылка),
		|	СопоставленнаяНоменклатураПоАртикулу.Идентификатор,
		|	КОЛИЧЕСТВО(СопоставленнаяНоменклатураПоАртикулу.Идентификатор)
		|ИЗ
		|	СопоставленнаяНоменклатураПоАртикулу КАК СопоставленнаяНоменклатураПоАртикулу
		|
		|СГРУППИРОВАТЬ ПО
		|	СопоставленнаяНоменклатураПоАртикулу.Идентификатор";

	Запрос.УстановитьПараметр("ДанныеДляСопоставления", ЗагружаемыеДанные);
	РезультатыЗапросов = Запрос.ВыполнитьПакет(); // Массив из РезультатЗапроса
	
	ТаблицаНоменклатура = РезультатыЗапросов[3].Выгрузить(); // ТаблицаЗначений
	Для каждого СтрокаТаблицы Из ЗагружаемыеДанные Цикл
		
		Товар = Товары.Добавить();
		Товар.Идентификатор = СтрокаТаблицы.Идентификатор;
		Товар.КоличествоУпаковок = СтрокаТаблицы.КоличествоУпаковок;
		
		СтрокаНоменклатура = ТаблицаНоменклатура.Найти(СтрокаТаблицы.Идентификатор, "Идентификатор");
		Если СтрокаНоменклатура <> Неопределено Тогда 
			Если СтрокаНоменклатура.Количество = 1 Тогда 
				Товар.Номенклатура = СтрокаНоменклатура.Ссылка; 
			ИначеЕсли СтрокаНоменклатура.Количество > 1 Тогда
				ЗаписьОНеоднозначности = СписокНеоднозначностей.Добавить();
				ЗаписьОНеоднозначности.Идентификатор = СтрокаТаблицы.Идентификатор;
				ЗаписьОНеоднозначности.Колонка = "Номенклатура";
			Иначе
				Продолжить;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры // } #wortmann

// Возвращает список подходящих объектов ИБ для неоднозначного значения ячейки.
// 
// Параметры:
//   ПолноеИмяТабличнойЧасти   - Строка - полное имя табличной части, в которую загружаются данные.
//   СписокНеоднозначностей    - Массив из СправочникСсылка._ДемоНоменклатура - массив для заполнения
//   с неоднозначными данными.
//   ИмяКолонки                - Строка - имя колонки, в который возникла неоднозначность.
//   ЗагружаемыеЗначенияСтрока - Строка - загружаемые данные на основании которых возникла неоднозначность.
//   ДополнительныеПараметры   - Произвольный - любые дополнительные сведения.
//
Процедура ЗаполнитьСписокНеоднозначностей(ПолноеИмяТабличнойЧасти, 
	СписокНеоднозначностей, 
	ИмяКолонки, 
	ЗагружаемыеЗначенияСтрока, 
	ДополнительныеПараметры) Экспорт
	
	Если ИмяКолонки = "Номенклатура" Тогда
		Запрос = Новый Запрос;
		
		ТекстГде = "";
		Если ЗначениеЗаполнено(ЗагружаемыеЗначенияСтрока.Номенклатура) Тогда
			ТекстГде = "ГДЕ Номенклатура.Наименование = &Наименование";
			Запрос.УстановитьПараметр("Наименование", ЗагружаемыеЗначенияСтрока.Номенклатура);
		КонецЕсли;
			
		Если ЗначениеЗаполнено(ЗагружаемыеЗначенияСтрока.Артикул) Тогда
			Если ЗначениеЗаполнено(ТекстГде) Тогда
				ТекстГде = ТекстГде + " ИЛИ _ДемоНоменклатура.Артикул = &Артикул";
			Иначе
				ТекстГде = "Номенклатура.Артикул = &Артикул";
			КонецЕсли;
			Запрос.УстановитьПараметр("Артикул", ЗагружаемыеЗначенияСтрока.Артикул);
		КонецЕсли;
		
		Запрос.Текст = "ВЫБРАТЬ
			|	Номенклатура.Ссылка КАК Ссылка
			|ИЗ
			|	Справочник.Номенклатура КАК Номенклатура " + ТекстГде;
		
		РезультатЗапроса = Запрос.Выполнить();
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			СписокНеоднозначностей.Добавить(ВыборкаДетальныеЗаписи.Ссылка);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
