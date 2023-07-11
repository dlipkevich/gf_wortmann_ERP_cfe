﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область ПрограммныйИнтерфейс

// #wortmann {
// #Отметка оригиналов документов
// Галфинд Окунев 2022/08/09
// Описывает учетные механизмы используемые в документе для регистрации в механизме проведения.
//
// Параметры:
//  МеханизмыДокумента - Массив - список имен учетных механизмов, для которых будет выполнена
//              регистрация в механизме проведения.
//
Процедура ЗарегистрироватьУчетныеМеханизмы(МеханизмыДокумента) Экспорт
	
	МеханизмыДокумента.Добавить("РеестрДокументов");
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #Отметка оригиналов документов
// Галфинд Окунев 2022/08/09
// Возвращает таблицы для движений, необходимые для проведения документа по регистрам учетных механизмов.
//
// Параметры:
//  Документ - ДокументСсылка - ссылка на документ, по которому необходимо получить данные
//  Регистры - Структура - список имен регистров, для которых необходимо получить таблицы
//  ДопПараметры - Структура - дополнительные параметры для получения данных, определяющие контекст проведения.
//
// Возвращаемое значение:
//  Структура - коллекция элементов - таблиц значений - данных для отражения в регистр.
//
Функция ДанныеДокументаДляПроведения(Документ, Регистры, ДопПараметры = Неопределено) Экспорт
	
	Если ДопПараметры = Неопределено Тогда
		
		ДопПараметры = ПроведениеДокументов.ДопПараметрыИнициализироватьДанныеДокументаДляПроведения();
		
	КонецЕсли;
	
	Запрос        = Новый Запрос;
	ТекстыЗапроса = Новый СписокЗначений;
	
	Если Не ДопПараметры.ПолучитьТекстыЗапроса Тогда
		
		ЗаполнитьПараметрыИнициализации(Запрос, Документ);
		
		ТекстЗапросаТаблицаРеестрДокументов(Запрос, ТекстыЗапроса, Регистры);
		
	КонецЕсли;
	
	Возврат ПроведениеДокументов.ИнициализироватьДанныеДокументаДляПроведения(Запрос, ТекстыЗапроса, ДопПараметры);
	
КонецФункции// } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/05
// Заполняет список команд печати.
//
// Параметры:
//   КомандыПечати - Массив - см. УправлениеПечатью.СоздатьКоллекциюКомандПечати.
//
Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
	
	КомандаПечати = КомандыПечати.Добавить();
	
	КомандаПечати.МенеджерПечати = "Документ.гф_СпецификацияПокупателя";
	КомандаПечати.Идентификатор  = "СпецификацияПокупателя";
	КомандаПечати.Представление  = "Спецификация покупателя";
	КомандаПечати.ПроверкаПроведенияПередПечатью = Ложь;
	
	КомандаПечати = КомандыПечати.Добавить();
	
	КомандаПечати.МенеджерПечати = "Документ.гф_СпецификацияПокупателя";
	КомандаПечати.Идентификатор  = "СпецификацияПоНовойЦене";
	КомандаПечати.Представление  = "Спецификация покупателя на остаток по новой цене";
	КомандаПечати.ПроверкаПроведенияПередПечатью = Ложь;
	КомандаПечати.Обработчик     = "гф_МенеджерПечатиКлиент.ПараметрыСпецификацииПоНовойЦене";
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/05
// Формирует печатные формы объектов.
//
// Параметры:
//
//   МассивОбъектов  		- Массив
//   ПараметрыПечати 		- Структура
//   КоллекцияПечатныхФорм	- ТаблицаЗначений
//   ОбъектыПечати			- СписокЗначений
//   ПараметрыВывода       	- Структура
//
Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "СпецификацияПокупателя") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"СпецификацияПокупателя",
		"Спецификация покупателя",
		СформироватьСпецификация(МассивОбъектов, ОбъектыПечати, ПараметрыПечати));
		
	КонецЕсли;
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "СпецификацияПоНовойЦене") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"СпецификацияПоНовойЦене",
		"Спецификация покупателя на остаток по новой цене",
		СформироватьСпецификация(МассивОбъектов,            ОбъектыПечати, ПараметрыПечати));
		
	КонецЕсли;
	
КонецПроцедуры// } #wortmann

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/05
// Создает табличный документ ПФ спецификации.
//
// Параметры:
//
//   МассивОбъектов  		- Массив
//   ОбъектыПечати			- СписокЗначений
//   ПараметрыПечати 		- Структура
//
// Возвращаемое значение:
//   - ТабличныйДокумент - печатная форма.
//
Функция СформироватьСпецификация(МассивОбъектов, ОбъектыПечати, ПараметрыПечати) Экспорт
	
	ПроблемыСПринтером = Ложь;
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	
	ТабличныйДокумент.АвтоМасштаб         = Истина;
	ТабличныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_СПЕЦИФИКАЦИЯПОКУПАТЕЛЯ";
	
	УстановитьПривилегированныйРежим(Истина);
	
	Макет = Документы.гф_СпецификацияПокупателя.ПолучитьМакет("СпецификацияПокупателя");
	
	ПервыйДокумент = Истина;
	
	Для Каждого СсылкаНаДокумент Из МассивОбъектов Цикл
		
		Если ПервыйДокумент Тогда
			
			ПервыйДокумент = Ложь;
			
		Иначе
			
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			
		КонецЕсли;
		
		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		
		ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
		ОбластьПодвал    = Макет.ПолучитьОбласть("Подвал");
		
		ПараметрыСпецификацииПоНовойЦене = Неопределено;
		
		ПараметрыПечати.Свойство("гф_Параметры", ПараметрыСпецификацииПоНовойЦене);
		
		ДанныеДляПечати = ДанныеДляПечатиСпецификации(СсылкаНаДокумент,
		ПараметрыСпецификацииПоНовойЦене);
		
		ФормированиеПечатныхФорм.ВывестиЛоготипВТабличныйДокумент(Макет,
		ОбластьЗаголовок,
		"ОбластьЗаголовок",
		ДанныеДляПечати.ДанныеШапки.Организация);
		
		СообщитьОНесколькихЦенах(ДанныеДляПечати.НесколькоЦен);
		
		ЗаполнитьЗначенияСвойств(ОбластьЗаголовок.Параметры, ДанныеДляПечати.ДанныеШапки);
		
		ТабличныйДокумент.Вывести(ОбластьЗаголовок);
		
		ПервичныеДокументыВКоробах = ДанныеДляПечати.ДанныеШапки.ПервичныеДокументыВКоробах;
		
		Подвал = Новый ТабличныйДокумент();
		
		Если ПервичныеДокументыВКоробах Тогда
			
			ПостфиксИмениМакета = "ВКоробах";
			
		Иначе
			
			ПостфиксИмениМакета = "";
			
		КонецЕсли;
		
		ОбластьИтоги = Макет.ПолучитьОбласть("Итого" + ПостфиксИмениМакета);
		
		ЗаполнитьЗначенияСвойств(ОбластьИтоги.Параметры, ДанныеДляПечати.ДанныеШапки);
		
		Подвал.Вывести(ОбластьИтоги);
		
		ЗаполнитьЗначенияСвойств(ОбластьПодвал.Параметры, ДанныеДляПечати.ДанныеШапки);
		
		Подвал.Вывести(ОбластьПодвал);
		
		ОбластьШапка = Макет.ПолучитьОбласть("Шапка" + ПостфиксИмениМакета);
		
		ТабличныйДокумент.Вывести(ОбластьШапка);
		
		НомерПоследнейСтроки = ДанныеДляПечати.ДанныеТабличнойЧасти.Количество();
		НомерСтроки          = 0;
		
		Для Каждого СтрокаДокумента Из ДанныеДляПечати.ДанныеТабличнойЧасти Цикл
			
			ВывестиСтрокуДокумента(СтрокаДокумента,
			Макет,
			ТабличныйДокумент,
			ПостфиксИмениМакета,
			НомерПоследнейСтроки,
			Подвал,
			ОбластьШапка);
			
		КонецЦикла;
		
		ТабличныйДокумент.Вывести(Подвал);
		
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(
		ТабличныйДокумент,
		НомерСтрокиНачало,
		ОбъектыПечати,
		СсылкаНаДокумент);
		
	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Ложь);
	
	Если ПроблемыСПринтером Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось определить высоту страницы. Возможно в системе не установлен принтер.");
		
	КонецЕсли;
	
	Возврат ТабличныйДокумент;
	
КонецФункции// } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/05
// Собщает пользователю о дублях цен.
//
// Параметры:
//
//   СтрокаДокумента		- СтрокаТаблицы
//   Макет 					- ТабличныйДокумент
//   ТабличныйДокумент		- ТабличныйДокумент
//   ПостфиксИмениМакета	- Строка
//   НомерПоследнейСтроки	- Число
//   Подвал 				- ТабличныйДокумент
//   ОбластьШапка 			- ТабличныйДокумент
//
Процедура ВывестиСтрокуДокумента(СтрокаДокумента,
	Макет,
	ТабличныйДокумент,
	ПостфиксИмениМакета,
	НомерПоследнейСтроки,
	Подвал,
	ОбластьШапка)
	
	НомерСтрокиПП = 0;
	НомерСтроки   = 0;
	
	Если Не ЗначениеЗаполнено(СтрокаДокумента.ЗаказПредставление) Тогда
		
		Возврат;
		
	ИначеЕсли Не ЗначениеЗаполнено(СтрокаДокумента.НоменклатураПредставление) Тогда
		
		ОбластьСтрока = Макет.ПолучитьОбласть("СтрокаЗаказ" + ПостфиксИмениМакета);
		
	Иначе
		
		ОбластьСтрока = Макет.ПолучитьОбласть("Строка" + ПостфиксИмениМакета);
		
		НомерСтрокиПП = НомерСтрокиПП + 1;
		
		ОбластьСтрока.Параметры.НомерСтрокиПП = НомерСтрокиПП;
		
	КонецЕсли;
	
	НомерСтроки = НомерСтроки + 1;
	
	ЗаполнитьЗначенияСвойств(ОбластьСтрока.Параметры, СтрокаДокумента);
	
	МассивПроверяемыхТаблиц = Новый Массив;
	
	МассивПроверяемыхТаблиц.Добавить(ОбластьСтрока);
	
	Если НомерСтроки = НомерПоследнейСтроки Тогда
		
		МассивПроверяемыхТаблиц.Добавить(Подвал);
		
	КонецЕсли;
	
	Попытка
		
		Если Не ТабличныйДокумент.ПроверитьВывод(МассивПроверяемыхТаблиц) Тогда
			
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			
			ТабличныйДокумент.Вывести(ОбластьШапка);
			
		КонецЕсли;
		
	Исключение
		
		ПроблемыСПринтером = Истина;
		
	КонецПопытки;
	
	ТабличныйДокумент.Вывести(ОбластьСтрока);
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/05
// Собщает пользователю о дублях цен.
//
// Параметры:
//
//   НесколькоЦен - Выборка - Выборка из результата запроса
//
Процедура СообщитьОНесколькихЦенах(НесколькоЦен)
	
	Пока НесколькоЦен.Следующий() Цикл
		
		СтрокаСообщения = "На артикул " + НесколькоЦен.Артикул + " в документах";
		
		ВыборкаЗаказов = НесколькоЦен.Выбрать();
		
		Первый = Истина;
		
		Пока ВыборкаЗаказов.Следующий() Цикл
			
			СтрокаСообщения = СтрокаСообщения + ?(Первый, " ", ", ") + ВыборкаЗаказов.Заказ;
			
			Первый = Ложь;
			
		КонецЦикла;
		
		СтрокаСообщения = СтрокаСообщения + " обнаружены разные цены.";
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СтрокаСообщения);
		
	КонецЦикла;
	
КонецПроцедуры// } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/05
// Собирает данные для печати спецификации.
//
// Параметры:
//
//   СсылкаНаДокумент					- ДокументСсылка
//   ПараметрыСпецификацииПоНовойЦене	- Структура
//
//	Возвращаемое значение:
//	- Структура - данные для печати.
//
Функция ДанныеДляПечатиСпецификации(СсылкаНаДокумент, ПараметрыСпецификацииПоНовойЦене = Неопределено)
	
	ПервичныеДокументыВКоробах = УправлениеСвойствами.ЗначениеСвойства(СсылкаНаДокумент.Договор,
	"гф_ДоговорыКонтрагентовПервичныеДокументыВКоробах");
	
	Если ПервичныеДокументыВКоробах = Неопределено Тогда
		
		ПервичныеДокументыВКоробах = Ложь;
		
	КонецЕсли;
	
	НаОстатокПоНовойЦене = ЗначениеЗаполнено(ПараметрыСпецификацииПоНовойЦене);
	
	РозничныеЦены = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту("Ключ",
	"гф_ГлобальныеЗначенияРозничнаяЦена");
	
	КодУпаковки = "778";
	
	ЕдиницаИзмеренияУпаковка = Справочники.УпаковкиЕдиницыИзмерения.НайтиПоКоду(КодУпаковки, , ,
	ПредопределенноеЗначение("Справочник.НаборыУпаковок.БазовыеЕдиницыИзмерения"));
	
	Запрос = Новый Запрос();
	
	Запрос.Текст = ТекстЗапросаДанныхПечатнойФормыСпецификации(ПервичныеДокументыВКоробах, НаОстатокПоНовойЦене);
	
	Запрос.Параметры.Вставить("СсылкаНаДокумент",           СсылкаНаДокумент);
	Запрос.Параметры.Вставить("МоментВремени", СсылкаНаДокумент.МоментВремени());
	Запрос.Параметры.Вставить("ТекущаяДата",   ТекущаяДатаСеанса());
	Запрос.Параметры.Вставить("ПервичныеДокументыВКоробах", ПервичныеДокументыВКоробах);
	Запрос.Параметры.Вставить("Упаковка",      ЕдиницаИзмеренияУпаковка);
	Запрос.Параметры.Вставить("РозничныеЦены", РозничныеЦены.Значение);
	Запрос.Параметры.Вставить("НаОстатокПоНовойЦене",       НаОстатокПоНовойЦене);
	
	Если НаОстатокПоНовойЦене Тогда
		
		Запрос.Параметры.Вставить("ДатаЦен",       ПараметрыСпецификацииПоНовойЦене.ДатаЦен);
		Запрос.Параметры.Вставить("ПрайсЛист",     ПараметрыСпецификацииПоНовойЦене.ПрайсЛист);
		Запрос.Параметры.Вставить("СкидкаКлиента", ПараметрыСпецификацииПоНовойЦене.СкидкаКлиента);
		
	Иначе
		
		Запрос.Параметры.Вставить("ДатаЦен",       ТекущаяДатаСеанса());
		Запрос.Параметры.Вставить("ПрайсЛист",     РозничныеЦены.Значение);
		Запрос.Параметры.Вставить("СкидкаКлиента", 0);
		
	КонецЕсли;
	
	Результаты = Запрос.ВыполнитьПакет();
	
	РазмерМассиваРезультатов = Результаты.Количество();
	
	СмещениеДублейЦен      = 3;
	СмещениеШапки          = 2;
	СмещениеТабличнойЧасти = 1;
	
	ИндексДублейЦен      = РазмерМассиваРезультатов - СмещениеДублейЦен;
	ИндексШапки          = РазмерМассиваРезультатов - СмещениеШапки;
	ИндексТабличнойЧасти = РазмерМассиваРезультатов - СмещениеТабличнойЧасти;
	
	ДанныеШапки = Новый Структура;
	
	ТаблицаШапки = Результаты[ИндексШапки].Выгрузить();
	
	СтрокаШапки = ТаблицаШапки[0];
	
	Для Каждого Колонка Из ТаблицаШапки.Колонки Цикл
		
		ДанныеШапки.Вставить(Колонка.Имя, СтрокаШапки[Колонка.Имя]);
		
	КонецЦикла;
	
	ДанныеШапки.Вставить("ЗаголовокСпецификации",
	"Спецификация № " + ДанныеШапки.Номер + " от " + Формат(
	ДанныеШапки.Дата,
	"ДФ=dd.MM.yyyy"));
	ДанныеШапки.Вставить("СуммаПрописью",
	ЧислоПрописью(
	ДанныеШапки.СуммаСНДС,
	"Л=ru_RU; ДП=Ложь",
	"рубль, рубля, рублей, м, копейка, копейки, копеек, ж"));
	
	СведенияОПоставщике = ФормированиеПечатныхФорм.СведенияОЮрФизЛице(ДанныеШапки.Организация, ДанныеШапки.Дата);
	
	ДанныеШапки.Вставить("ДатаДоговораСтрока", Формат(ДанныеШапки.ДатаДоговора, "ДЛФ=DD"));
	ДанныеШапки.Вставить("Банк");
	ДанныеШапки.Вставить("БИК");
	ДанныеШапки.Вставить("КоррСчет");
	ДанныеШапки.Вставить("НомерСчета");
	ДанныеШапки.Вставить("ИНН");
	ДанныеШапки.Вставить("КПП");
	ДанныеШапки.Вставить("НаименованиеДляПечатныхФорм");
	
	ЗаполнитьЗначенияСвойств(ДанныеШапки, СведенияОПоставщике);
	
	
	ДанныеШапки.Вставить("ПредставлениеПоставщика",
	ФормированиеПечатныхФорм.ОписаниеОрганизации(
	ФормированиеПечатныхФорм.СведенияОЮрФизЛице(
	ДанныеШапки.Организация,
	ДанныеШапки.Дата),
	"ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	
	ДанныеШапки.Вставить("ПредставлениеПолучателя",
	ФормированиеПечатныхФорм.ОписаниеОрганизации(
	ФормированиеПечатныхФорм.СведенияОЮрФизЛице(
	ДанныеШапки.Контрагент,
	ДанныеШапки.Дата),
	"ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	
	ДанныеШапки.Вставить("ПредставлениеГрузоотправителя",
	ФормированиеПечатныхФорм.ОписаниеОрганизации(
	ФормированиеПечатныхФорм.СведенияОЮрФизЛице(
	ДанныеШапки.Организация,
	ДанныеШапки.Дата),
	"ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	
	ДанныеШапки.Вставить("ПредставлениеГрузополучателя",
	ФормированиеПечатныхФорм.ОписаниеОрганизации(
	ФормированиеПечатныхФорм.СведенияОЮрФизЛице(
	ДанныеШапки.Контрагент,
	ДанныеШапки.Дата),
	"ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	
	ОтветственныеЛица = ОтветственныеЛицаСервер.ПолучитьОтветственныеЛицаОрганизации(ДанныеШапки.Организация);
	
	ДанныеШапки.Вставить("ФИОРуководителя",       ФизическиеЛицаУТ.ФамилияИнициалыФизЛица(ОтветственныеЛица.Руководитель));
	ДанныеШапки.Вставить("РуководительДолжность",
	ФизическиеЛицаУТ.ФамилияИнициалыФизЛица(
	ОтветственныеЛица.РуководительДолжность));
	ДанныеШапки.Вставить("ФИОБухгалтера", ФизическиеЛицаУТ.ФамилияИнициалыФизЛица(ОтветственныеЛица.ГлавныйБухгалтер));
	
	
	НесколькоЦен         = Результаты[ИндексДублейЦен].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	ДанныеТабличнойЧасти = Результаты[ИндексТабличнойЧасти].Выгрузить();
	
	Для Каждого СтрокаТовара Из ДанныеТабличнойЧасти Цикл
		
		Если СтрокаТовара.Номенклатура = Null Тогда
			
			СтрокаТовара.ЗаказПредставление = СтрокаТовара.ЗаказНомер + " от " + Формат(СтрокаТовара.ЗаказДата,
			"ДФ=dd.MM.yyyy");
			
			Продолжить;
			
		КонецЕсли;
		
		ПредставлениеИнтервала = ПредставлениеИнтервала(СтрокаТовара.ДатаОтгрузки);
		
		СтрокаТовара.НоменклатураПредставление = СтрокаТовара.НоменклатураПредставление + ПредставлениеИнтервала;
		
	КонецЦикла;
	
	Результат = Новый Структура("ДанныеШапки, ДанныеТабличнойЧасти, НесколькоЦен",
	ДанныеШапки,
	ДанныеТабличнойЧасти,
	НесколькоЦен);
	
	Возврат Результат;
	
КонецФункции// } #wortmann

// #Спецификация покупателя
// Галфинд Окунев 2022/09/07
// Представление интервала доствки для печати.
//
// Параметры:
//
// ДатаОтгрузки - Дата
//
//	Возвращаемое значение:
//	- Строка - Представление интервала.
//
Функция ПредставлениеИнтервала(Знач ДатаОтгрузки);
	
	ДнейВВисокосномГоду        = 366;
	НомерДня28Февраля          = 59;
	НачалоВторойПоловиныМесяца = 16;
	
	Если ДеньГода(КонецГода(ДатаОтгрузки)) = ДнейВВисокосномГоду И ДеньГода(ДатаОтгрузки) = НомерДня28Февраля Тогда
		
		ДатаОтгрузки = НачалоДня(КонецМесяца(ДатаОтгрузки));
		
	Иначе
		
		ДатаОтгрузки = НачалоДня(ДатаОтгрузки);
		
	КонецЕсли;
	
	Если ДатаОтгрузки = НачалоДня(КонецМесяца(ДатаОтгрузки)) Тогда
		
		ПредставлениеИнтервала = " (" + Формат(
		Дата(Год(ДатаОтгрузки), Месяц(ДатаОтгрузки), НачалоВторойПоловиныМесяца),
		"ДФ=dd.MM.yyyy")
		+ " - " + Формат(ДатаОтгрузки, "ДФ=dd.MM.yyyy") + ")";
		
	ИначеЕсли День(ДатаОтгрузки) = НачалоВторойПоловиныМесяца Тогда
		
		ПредставлениеИнтервала = " (" + Формат(
		НачалоМесяца(ДатаОтгрузки),
		"ДФ=dd.MM.yyyy")
		+ " - " + Формат(ДатаОтгрузки, "ДФ=dd.MM.yyyy") + ")";
		
	Иначе
		
		ПредставлениеИнтервала = "";
		
	КонецЕсли;
	
	Возврат ПредставлениеИнтервала;
	
КонецФункции// } #wortmann


// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/05
// Текст запроса
//
// BSLLS:MethodSize-off
// разбиение текста запроса на несколько затрудняет отладку.
//
// Параметры:
//	ПервичныеДокументыВКоробах - Булево
//	НаОстатокПоНовойЦене - Булево
//
// Возвращаемое значение:
// - Строка - текст запроса
//
Функция ТекстЗапросаДанныхПечатнойФормыСпецификации(ПервичныеДокументыВКоробах, НаОстатокПоНовойЦене)
	
	Результат = "ВЫБРАТЬ ПЕРВЫЕ 1
	|	&ТекущаяДата КАК ТекущаяДата,
	|	гф_СпецификацияПокупателя.Номер КАК Номер,
	|	гф_СпецификацияПокупателя.Дата КАК Дата,
	|	гф_СпецификацияПокупателя.Организация КАК Организация,
	|	гф_СпецификацияПокупателя.Контрагент КАК Контрагент,
	|	гф_СпецификацияПокупателя.Договор КАК Договор,
	|	гф_СпецификацияПокупателя.Ответственный КАК Ответственный,
	|	ВЫРАЗИТЬ(гф_СпецификацияПокупателя.Комментарий КАК СТРОКА(100)) КАК Комментарий,
	|	Организации.Представление КАК ОрганизацияПредставление,
	|	Контрагенты.Представление КАК КонтрагентПредставление,
	|	ДоговорыКонтрагентов.Дата КАК ДатаДоговора,
	|	ДоговорыКонтрагентов.Номер КАК НомерДоговора,
	|	ДоговорыКонтрагентов.Представление КАК ДоговорПредставление,
	|	гф_СпецификацияПокупателя.Ссылка КАК Спецификация,
	|	&ПервичныеДокументыВКоробах КАК ПервичныеДокументыВКоробах,
	|	&НаОстатокПоНовойЦене КАК НаОстатокПоНовойЦене
	|ПОМЕСТИТЬ ВТ_Шапка
	|ИЗ
	|	Документ.гф_СпецификацияПокупателя КАК гф_СпецификацияПокупателя
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|		ПО гф_СпецификацияПокупателя.Договор = ДоговорыКонтрагентов.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Контрагенты
	|		ПО гф_СпецификацияПокупателя.Контрагент = Контрагенты.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Организации КАК Организации
	|		ПО гф_СпецификацияПокупателя.Организация = Организации.Ссылка
	|ГДЕ
	|	гф_СпецификацияПокупателя.Ссылка = &СсылкаНаДокумент
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СтавкиНДС.Ссылка КАК Ссылка,
	|	СтавкиНДС.Ставка КАК Ставка
	|ПОМЕСТИТЬ ВТ_СтавкиНДС
	|ИЗ
	|	Справочник.СтавкиНДС КАК СтавкиНДС
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Заказы.ЗаказКлиента КАК Заказ,
	|	ЗаказКлиентаДокумент.Представление КАК ЗаказПредставление,
	|	ЗаказКлиентаДокумент.Номер КАК ЗаказНомер,
	|	ЗаказКлиентаДокумент.Дата КАК ЗаказДата,
	|	ЗаказКлиентаДокумент.гф_ИмяЗаказа КАК ИмяЗаказа
	|ПОМЕСТИТЬ ВТ_Заказы
	|ИЗ
	|	ВТ_Шапка КАК ВТ_Шапка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.гф_СпецификацияПокупателя.ЗаказыКлиентов КАК Заказы
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ЗаказКлиентаДокумент
	|			ПО Заказы.ЗаказКлиента = ЗаказКлиентаДокумент.Ссылка
	|		ПО ВТ_Шапка.Спецификация = Заказы.Ссылка
	|ГДЕ
	|	НЕ Заказы.ЗаказКлиента ЕСТЬ NULL
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации КАК ВариантКомплектации
	|ПОМЕСТИТЬ ВТ_Подзапрос1
	|ИЗ
	|	ВТ_Заказы КАК ВТ_Заказы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.гф_ТоварыВКоробах КАК ЗаказКлиентагф_ТоварыВКоробах
	|		ПО ВТ_Заказы.Заказ = ЗаказКлиентагф_ТоварыВКоробах.Ссылка
	|ГДЕ
	|	НЕ ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации ЕСТЬ NULL
	
	|СГРУППИРОВАТЬ ПО
	|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВариантыКомплектацииНоменклатурыТовары.Ссылка КАК ВариантКомплектации,
	|	ВариантыКомплектацииНоменклатурыТовары.Номенклатура КАК Номенклатура,
	|	СУММА(ВариантыКомплектацииНоменклатурыТовары.Количество) КАК Количество
	|ПОМЕСТИТЬ ВТ_ВариантыКомплектации
	|ИЗ
	|	ВТ_Подзапрос1 КАК Подзапрос
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВариантыКомплектацииНоменклатуры.Товары КАК ВариантыКомплектацииНоменклатурыТовары
	|		ПО Подзапрос.ВариантКомплектации = ВариантыКомплектацииНоменклатурыТовары.Ссылка
	|ГДЕ
	|	&ПервичныеДокументыВКоробах = ИСТИНА
	|	И НЕ ВариантыКомплектацииНоменклатурыТовары.Номенклатура ЕСТЬ NULL
	
	|СГРУППИРОВАТЬ ПО
	|	ВариантыКомплектацииНоменклатурыТовары.Ссылка,
	|	ВариантыКомплектацииНоменклатурыТовары.Номенклатура
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура
	|ПОМЕСТИТЬ ВТ_Номенклатура
	|ИЗ
	|	ВТ_Заказы КАК ВТ_Заказы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	|		ПО ВТ_Заказы.Заказ = ЗаказКлиентаТовары.Ссылка
	|ГДЕ
	|	&ПервичныеДокументыВКоробах = ЛОЖЬ
	|	И НЕ ЗаказКлиентаТовары.Номенклатура ЕСТЬ NULL
	
	|ОБЪЕДИНИТЬ ВСЕ
	
	|ВЫБРАТЬ
	|	ВТ_ВариантыКомплектации.Номенклатура
	|ИЗ
	|	ВТ_ВариантыКомплектации КАК ВТ_ВариантыКомплектации
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Цены.Номенклатура КАК Номенклатура,
	|	МАКСИМУМ(ВЫБОР
	|			КОГДА Цены.ВидЦены = &РозничныеЦены
	|				ТОГДА ЕСТЬNULL(Цены.Цена, 0)
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК РозничнаяЦена,
	|	МАКСИМУМ(ВЫБОР
	|			КОГДА Цены.ВидЦены = &ПрайсЛист
	|				ТОГДА ЕСТЬNULL(Цены.Цена, 0)
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК НоваяЦена
	|ПОМЕСТИТЬ ВТ_Цены
	|ИЗ
	|	РегистрСведений.ЦеныНоменклатуры25.СрезПоследних(
	|			&МоментВремени,
	|			ВидЦены В (&РозничныеЦены, &ПрайсЛист)
	|				И Номенклатура В
	|					(ВЫБРАТЬ
	|						Т.Номенклатура
	|					ИЗ
	|						ВТ_Номенклатура КАК Т)) КАК Цены
	
	|СГРУППИРОВАТЬ ПО
	|	Цены.Номенклатура
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
	|	МАКСИМУМ(ЗаказКлиентаТовары.ДатаОтгрузки) КАК ДатаОтгрузки
	|ПОМЕСТИТЬ ВТ_ДатыОтгрузки
	|ИЗ
	|	ВТ_Заказы КАК ВТ_Заказы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	|		ПО ВТ_Заказы.Заказ = ЗаказКлиентаТовары.Ссылка
	|ГДЕ
	|	НЕ ЗаказКлиентаТовары.Номенклатура ЕСТЬ NULL
	
	|СГРУППИРОВАТЬ ПО
	|	ЗаказКлиентаТовары.Номенклатура
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Заказы.Заказ КАК Заказ,
	|	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
	|	ЗаказКлиентаТовары.Характеристика КАК Характеристика,
	|	ЗаказКлиентаТовары.Количество КАК Количество,
	|	ЗаказКлиентаТовары.Цена КАК Цена,
	|	ЗаказКлиентаТовары.ПроцентРучнойСкидки КАК ПроцентРучнойСкидки,
	|	ЗаказКлиентаТовары.ПроцентАвтоматическойСкидки КАК ПроцентАвтоматическойСкидки,
	|	ЗаказКлиентаТовары.СтавкаНДС КАК СтавкаНДС,
	|	ЗаказКлиентаТовары.ВариантОбеспечения КАК ВариантОбеспечения,
	|	ЗаказКлиентаТовары.ДатаОтгрузки КАК ДатаОтгрузки
	|ПОМЕСТИТЬ ВТ_Подзапрос2
	|ИЗ
	|	ВТ_Заказы КАК ВТ_Заказы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	|		ПО (ЗаказКлиентаТовары.Ссылка = ВТ_Заказы.Заказ)
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Заказы.Заказ КАК Заказ,
	|	ТоварыВКоробах.ВариантКомплектации КАК ВариантКомплектации,
	|	ТоварыВКоробах.Количество КАК Количество,
	|	ТоварыВКоробах.ЦенаКороба КАК Цена,
	|	ТоварыВКоробах.Скидка КАК Скидка,
	|	ТоварыВКоробах.СтавкаНДС КАК СтавкаНДС,
	|	ТоварыВКоробах.ВариантОбеспечения КАК ВариантОбеспечения
	|ПОМЕСТИТЬ ВТ_Подзапрос3
	|ИЗ
	|	ВТ_Заказы КАК ВТ_Заказы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.гф_ТоварыВКоробах КАК ТоварыВКоробах
	|		ПО (ТоварыВКоробах.Ссылка = ВТ_Заказы.Заказ)
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Подзапрос.Заказ КАК Заказ,
	|	Подзапрос.Номенклатура КАК Номенклатура,
	|	Подзапрос.Характеристика КАК Характеристика,
	|	Подзапрос.Количество КАК Количество,
	|	Подзапрос.Количество КАК КоличествоВКоробе,
	|	Подзапрос.СтавкаНДС КАК СтавкаНДС,
	|	ВЫБОР
	|		КОГДА &НаОстатокПоНовойЦене = ИСТИНА
	|			ТОГДА ВЫРАЗИТЬ(ЕСТЬNULL(Цены.НоваяЦена, 0) * (1 - &СкидкаКлиента / 100) КАК ЧИСЛО(15, 2))
	|		ИНАЧЕ ВЫРАЗИТЬ(Подзапрос.Цена * (1 - Подзапрос.ПроцентРучнойСкидки / 100) * (1 - Подзапрос.ПроцентАвтоматическойСкидки / 100) КАК ЧИСЛО(15, 2))
	|	КОНЕЦ КАК Цена,
	|	ЕСТЬNULL(Цены.РозничнаяЦена, 0) КАК РекомендуемаяРозничнаяЦена,
	|	СтавкиНДС.Ставка КАК СтавкаНДСЧисло,
	|	Подзапрос.ДатаОтгрузки КАК ДатаОтгрузки
	|ПОМЕСТИТЬ ВТ_ПозицииНоменклатуры
	|ИЗ
	|	ВТ_Подзапрос2 КАК Подзапрос
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтавкиНДС КАК СтавкиНДС
	|		ПО Подзапрос.СтавкаНДС = СтавкиНДС.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Цены КАК Цены
	|		ПО Подзапрос.Номенклатура = Цены.Номенклатура
	|ГДЕ
	|	&ПервичныеДокументыВКоробах = ЛОЖЬ
	|	И ВЫБОР
	|			КОГДА &НаОстатокПоНовойЦене = ИСТИНА
	|				ТОГДА Подзапрос.ВариантОбеспечения = ЗНАЧЕНИЕ(Перечисление.ВариантыОбеспечения.КОбеспечению)
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	
	|ОБЪЕДИНИТЬ ВСЕ
	
	|ВЫБРАТЬ
	|	Подзапрос.Заказ,
	|	ВТ_ВариантыКомплектации.Номенклатура,
	|	ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка),
	|	Подзапрос.Количество,
	|	ВТ_ВариантыКомплектации.Количество,
	|	Подзапрос.СтавкаНДС,
	|	ВЫБОР
	|		КОГДА &НаОстатокПоНовойЦене = ИСТИНА
	|			ТОГДА ВЫРАЗИТЬ(ЕСТЬNULL(Цены.НоваяЦена, 0) * ВТ_ВариантыКомплектации.Количество * (1 - &СкидкаКлиента / 100) КАК ЧИСЛО(15, 2))
	|		ИНАЧЕ ВЫРАЗИТЬ(Подзапрос.Цена * (1 - Подзапрос.Скидка / 100) КАК ЧИСЛО(15, 2))
	|	КОНЕЦ,
	|	ЕСТЬNULL(Цены.РозничнаяЦена, 0),
	|	СтавкиНДС.Ставка,
	|	ВТ_ДатыОтгрузки.ДатаОтгрузки
	|ИЗ
	|	ВТ_Подзапрос3 КАК Подзапрос
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ВариантыКомплектации КАК ВТ_ВариантыКомплектации
	|			ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ДатыОтгрузки КАК ВТ_ДатыОтгрузки
	|			ПО ВТ_ВариантыКомплектации.Номенклатура = ВТ_ДатыОтгрузки.Номенклатура
	|		ПО Подзапрос.ВариантКомплектации = ВТ_ВариантыКомплектации.ВариантКомплектации
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтавкиНДС КАК СтавкиНДС
	|		ПО Подзапрос.СтавкаНДС = СтавкиНДС.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Цены КАК Цены
	|		ПО (ВТ_ВариантыКомплектации.Номенклатура = Цены.Номенклатура)
	|ГДЕ
	|	&ПервичныеДокументыВКоробах = ИСТИНА
	|	И ВЫБОР
	|			КОГДА &НаОстатокПоНовойЦене = ИСТИНА
	|				ТОГДА Подзапрос.ВариантОбеспечения = ЗНАЧЕНИЕ(Перечисление.ВариантыОбеспечения.КОбеспечению)
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ПозицииНоменклатуры.Заказ КАК Заказ,
	|	ВТ_Заказы.ЗаказПредставление КАК ЗаказПредставление,
	|	ВТ_Заказы.ЗаказНомер КАК ЗаказНомер,
	|	ВТ_Заказы.ЗаказДата КАК ЗаказДата,
	|	ВТ_Заказы.ИмяЗаказа КАК ИмяЗаказа,
	|	ВТ_ПозицииНоменклатуры.ДатаОтгрузки КАК ДатаОтгрузки,
	|	ВТ_ПозицииНоменклатуры.Номенклатура КАК Номенклатура,
	|	НоменклатураСправочник.НаименованиеПолное КАК НоменклатураПредставление,
	|	НоменклатураСправочник.Артикул КАК Артикул,
	|	ВТ_ПозицииНоменклатуры.Характеристика КАК Характеристика,
	|	ВТ_ПозицииНоменклатуры.Количество КАК Количество,
	|	НоменклатураСправочник.ЕдиницаДляОтчетов КАК ЕдиницаДляОтчетов,
	|	ВЫБОР
	|		КОГДА &ПервичныеДокументыВКоробах = ИСТИНА
	|			ТОГДА ВТ_ПозицииНоменклатуры.Количество * ВТ_ПозицииНоменклатуры.КоличествоВКоробе
	|		ИНАЧЕ ВТ_ПозицииНоменклатуры.Количество
	|	КОНЕЦ КАК ОбщееКоличество,
	|	ВЫБОР
	|		КОГДА &ПервичныеДокументыВКоробах = ИСТИНА
	|			ТОГДА ВТ_ПозицииНоменклатуры.Количество
	|		ИНАЧЕ 1
	|	КОНЕЦ КАК КоличествоКоробов,
	|	ВТ_ПозицииНоменклатуры.КоличествоВКоробе КАК КоличествоВКоробе,
	|	ВТ_ПозицииНоменклатуры.СтавкаНДС КАК СтавкаНДС,
	|	ВЫБОР
	|		КОГДА &ПервичныеДокументыВКоробах = ИСТИНА
	|			ТОГДА ВТ_ПозицииНоменклатуры.Цена / ВТ_ПозицииНоменклатуры.КоличествоВКоробе
	|		ИНАЧЕ ВТ_ПозицииНоменклатуры.Цена
	|	КОНЕЦ КАК Цена,
	|	ВЫБОР
	|		КОГДА &ПервичныеДокументыВКоробах = ИСТИНА
	|			ТОГДА ВТ_ПозицииНоменклатуры.Цена
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК ЦенаЗаКороб,
	|	ВТ_ПозицииНоменклатуры.РекомендуемаяРозничнаяЦена КАК РекомендуемаяРозничнаяЦена,
	|	ВТ_ПозицииНоменклатуры.СтавкаНДСЧисло КАК СтавкаНДСЧисло,
	|	ВЫРАЗИТЬ(ВТ_ПозицииНоменклатуры.Количество * ВТ_ПозицииНоменклатуры.Цена КАК ЧИСЛО(15, 2)) КАК Сумма,
	|	ВЫРАЗИТЬ(ВТ_ПозицииНоменклатуры.Количество * ВТ_ПозицииНоменклатуры.Цена * ВТ_ПозицииНоменклатуры.СтавкаНДСЧисло / 100 КАК ЧИСЛО(15, 2)) КАК СуммаНДС,
	|	ВЫРАЗИТЬ(ВТ_ПозицииНоменклатуры.Количество * ВТ_ПозицииНоменклатуры.Цена * (100 + ВТ_ПозицииНоменклатуры.СтавкаНДСЧисло) / 100 КАК ЧИСЛО(15, 2)) КАК СуммаСНДС,
	|	ХарактеристикиНоменклатуры.НаименованиеПолное КАК Размер
	|ПОМЕСТИТЬ ВТ_НоменклатураСуммы
	|ИЗ
	|	ВТ_ПозицииНоменклатуры КАК ВТ_ПозицииНоменклатуры
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК НоменклатураСправочник
	|		ПО ВТ_ПозицииНоменклатуры.Номенклатура = НоменклатураСправочник.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Заказы КАК ВТ_Заказы
	|		ПО ВТ_ПозицииНоменклатуры.Заказ = ВТ_Заказы.Заказ
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ХарактеристикиНоменклатуры КАК ХарактеристикиНоменклатуры
	|		ПО ВТ_ПозицииНоменклатуры.Характеристика = ХарактеристикиНоменклатуры.Ссылка
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(СУММА(ВТ_НоменклатураСуммы.Количество), 0) КАК Количество,
	|	ЕСТЬNULL(СУММА(ВТ_НоменклатураСуммы.КоличествоКоробов), 0) КАК КоличествоКоробов,
	|	ЕСТЬNULL(СУММА(ВТ_НоменклатураСуммы.Сумма), 0) КАК Сумма,
	|	ЕСТЬNULL(СУММА(ВТ_НоменклатураСуммы.СуммаНДС), 0) КАК СуммаНДС,
	|	ЕСТЬNULL(СУММА(ВТ_НоменклатураСуммы.СуммаСНДС), 0) КАК СуммаСНДС
	|ПОМЕСТИТЬ ВТ_Итоги
	|ИЗ
	|	ВТ_НоменклатураСуммы КАК ВТ_НоменклатураСуммы
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ПозицииНоменклатуры.Номенклатура КАК Номенклатура,
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВТ_ПозицииНоменклатуры.Цена) КАК КоличествоЦен
	|ПОМЕСТИТЬ ВТ_Подзапрос4
	|ИЗ
	|	ВТ_ПозицииНоменклатуры КАК ВТ_ПозицииНоменклатуры
	
	|СГРУППИРОВАТЬ ПО
	|	ВТ_ПозицииНоменклатуры.Номенклатура
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Подзапрос.Номенклатура КАК Номенклатура,
	|	Подзапрос.КоличествоЦен КАК КоличествоЦен,
	|	ВТ_ПозицииНоменклатуры.Заказ КАК Заказ,
	|	НоменклатураСправочник.Артикул КАК Артикул
	|ИЗ
	|	ВТ_Подзапрос4 КАК Подзапрос
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ПозицииНоменклатуры КАК ВТ_ПозицииНоменклатуры
	|		ПО Подзапрос.Номенклатура = ВТ_ПозицииНоменклатуры.Номенклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК НоменклатураСправочник
	|		ПО Подзапрос.Номенклатура = НоменклатураСправочник.Ссылка
	|ГДЕ
	|	Подзапрос.КоличествоЦен > 1
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Шапка.ТекущаяДата КАК ТекущаяДата,
	|	ВТ_Шапка.Номер КАК Номер,
	|	ВТ_Шапка.Дата КАК Дата,
	|	ВТ_Шапка.Организация КАК Организация,
	|	ВТ_Шапка.Контрагент КАК Контрагент,
	|	ВТ_Шапка.Договор КАК Договор,
	|	ВТ_Шапка.Ответственный КАК Ответственный,
	|	ВТ_Шапка.Комментарий КАК Комментарий,
	|	ВТ_Шапка.ОрганизацияПредставление КАК ОрганизацияПредставление,
	|	ВТ_Шапка.КонтрагентПредставление КАК КонтрагентПредставление,
	|	ВТ_Шапка.ДатаДоговора КАК ДатаДоговора,
	|	ВТ_Шапка.НомерДоговора КАК НомерДоговора,
	|	ВТ_Шапка.ДоговорПредставление КАК ДоговорПредставление,
	|	ВТ_Шапка.Спецификация КАК Спецификация,
	|	ВТ_Шапка.ПервичныеДокументыВКоробах КАК ПервичныеДокументыВКоробах,
	|	ВТ_Итоги.Количество КАК Количество,
	|	ВТ_Итоги.КоличествоКоробов КАК КоличествоКоробов,
	|	ВТ_Итоги.Сумма КАК Сумма,
	|	ВТ_Итоги.СуммаНДС КАК СуммаНДС,
	|	ВТ_Итоги.СуммаСНДС КАК СуммаСНДС
	|ИЗ
	|	ВТ_Шапка КАК ВТ_Шапка,
	|	ВТ_Итоги КАК ВТ_Итоги
	
	|СГРУППИРОВАТЬ ПО
	|	ВТ_Шапка.Договор,
	|	ВТ_Шапка.Ответственный,
	|	ВТ_Шапка.НомерДоговора,
	|	ВТ_Шапка.Номер,
	|	ВТ_Шапка.Контрагент,
	|	ВТ_Шапка.ДатаДоговора,
	|	ВТ_Шапка.КонтрагентПредставление,
	|	ВТ_Шапка.ОрганизацияПредставление,
	|	ВТ_Шапка.ДоговорПредставление,
	|	ВТ_Шапка.ТекущаяДата,
	|	ВТ_Шапка.Комментарий,
	|	ВТ_Шапка.Организация,
	|	ВТ_Шапка.Дата,
	|	ВТ_Шапка.ПервичныеДокументыВКоробах,
	|	ВТ_Шапка.Спецификация,
	|	ВТ_Итоги.Количество,
	|	ВТ_Итоги.КоличествоКоробов,
	|	ВТ_Итоги.Сумма,
	|	ВТ_Итоги.СуммаНДС,
	|	ВТ_Итоги.СуммаСНДС
	|;
	
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗаказКлиента.Ссылка КАК Заказ,
	|	ЗаказКлиента.Представление КАК ЗаказПредставление,
	|	ЗаказКлиента.Номер КАК ЗаказНомер,
	|	ЗаказКлиента.Дата КАК ЗаказДата,
	|	ЗаказКлиента.гф_ИмяЗаказа КАК ИмяЗаказа,
	|	ВТ_НоменклатураСуммы.Размер КАК Размер,
	|	ВТ_НоменклатураСуммы.Номенклатура КАК Номенклатура,
	|	ВТ_НоменклатураСуммы.НоменклатураПредставление КАК НоменклатураПредставление,
	|	ВТ_НоменклатураСуммы.ДатаОтгрузки КАК ДатаОтгрузки,
	|	ВТ_НоменклатураСуммы.КоличествоВКоробе КАК КоличествоВКоробе,
	|	ВТ_НоменклатураСуммы.Количество КАК Количество,
	|	ВТ_НоменклатураСуммы.ОбщееКоличество КАК ОбщееКоличество,
	|	ВТ_НоменклатураСуммы.КоличествоКоробов КАК КоличествоКоробов,
	|	ВТ_НоменклатураСуммы.РекомендуемаяРозничнаяЦена КАК РекомендуемаяРозничнаяЦена,
	|	ВТ_НоменклатураСуммы.Цена КАК Цена,
	|	ВТ_НоменклатураСуммы.ЦенаЗаКороб КАК ЦенаЗаКороб,
	|	ВТ_НоменклатураСуммы.Артикул КАК Артикул,
	|	ВТ_НоменклатураСуммы.ЕдиницаДляОтчетов КАК ЕдиницаДляОтчетов,
	|	ВТ_НоменклатураСуммы.СтавкаНДС КАК СтавкаНДС,
	|	ВТ_НоменклатураСуммы.СтавкаНДСЧисло КАК СтавкаНДСЧисло,
	|	ВТ_НоменклатураСуммы.Сумма КАК Сумма,
	|	ВТ_НоменклатураСуммы.СуммаНДС КАК СуммаНДС,
	|	ВТ_НоменклатураСуммы.СуммаСНДС КАК СуммаСНДС
	|ИЗ
	|	ВТ_НоменклатураСуммы КАК ВТ_НоменклатураСуммы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ЗаказКлиента
	|		ПО ВТ_НоменклатураСуммы.Заказ = ЗаказКлиента.Ссылка
	
	|УПОРЯДОЧИТЬ ПО
	|	ЗаказДата,
	|	ЗаказНомер,
	|	Артикул,
	|	НоменклатураПредставление,
	|	Размер
	|ИТОГИ
	|	СУММА(Количество),
	|	СУММА(КоличествоКоробов),
	|	СУММА(Сумма),
	|	СУММА(СуммаНДС),
	|	СУММА(СуммаСНДС)
	|ПО
	|	Заказ";
	
	Возврат Результат;
	
КонецФункции// } #wortmann
// BSLLS:MethodSize-on

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/05
// Текст запроса выбора строк печатной формы.
//
// Параметры:
//  Запрос			- Строка
//  ДокументСсылка	- ДокументСсылка
//
Процедура ЗаполнитьПараметрыИнициализации(Запрос, ДокументСсылка)
	
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
	Запрос.УстановитьПараметр("Ссылка", ДокументСсылка);
	
	Запрос.Текст = "ВЫБРАТЬ
	|	ДанныеШапки.Дата КАК Период,
	|	Контрагенты.Партнер КАК Партнер,
	|	ДанныеШапки.Контрагент КАК Контрагент,
	|	ДанныеШапки.Организация КАК Организация,
	|	ДанныеШапки.Договор КАК Договор,
	|	ДанныеШапки.Ответственный КАК Ответственный,
	|	ДанныеШапки.Комментарий КАК Комментарий,
	|	ДанныеШапки.Ссылка КАК Ссылка,
	|	ДанныеШапки.Номер КАК Номер,
	|	ДанныеШапки.Проведен КАК Проведен,
	|	ДанныеШапки.ПометкаУдаления КАК ПометкаУдаления
	|ИЗ
	|	Документ.гф_СпецификацияПокупателя КАК ДанныеШапки
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Контрагенты
	|		ПО ДанныеШапки.Контрагент = Контрагенты.Ссылка
	|ГДЕ
	|	ДанныеШапки.Ссылка = &Ссылка";
	
	Реквизиты = Запрос.Выполнить().Выбрать();
	
	Реквизиты.Следующий();
	
	Запрос.УстановитьПараметр("Период",     Реквизиты.Период);
	Запрос.УстановитьПараметр("Партнер",    Реквизиты.Партнер);
	Запрос.УстановитьПараметр("Организация",             Реквизиты.Организация);
	Запрос.УстановитьПараметр("Договор",    Реквизиты.Договор);
	Запрос.УстановитьПараметр("Контрагент", Реквизиты.Контрагент);
	Запрос.УстановитьПараметр("Номер",      Реквизиты.Номер);
	Запрос.УстановитьПараметр("Ответственный",           Реквизиты.Ответственный);
	Запрос.УстановитьПараметр("Комментарий",             Реквизиты.Комментарий);
	Запрос.УстановитьПараметр("Проведен",   Реквизиты.Проведен);
	Запрос.УстановитьПараметр("ПометкаУдаления",         Реквизиты.ПометкаУдаления);
	Запрос.УстановитьПараметр("ИдентификаторМетаданных",
	ОбщегоНазначения.ИдентификаторОбъектаМетаданных(
	ТипЗнч(
	ДокументСсылка)));
	
	ИнформацияПоДоговору = Неопределено;
	
	Если ЗначениеЗаполнено(Реквизиты.Договор) Тогда
		
		ИнформацияПоДоговору = НСтр("ru = 'По договору ""%Договор%""';
		|en = 'Under the ""%Договор%"" contract'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
		
		ИнформацияПоДоговору = СтрЗаменить(ИнформацияПоДоговору, "%Договор%", Реквизиты.Договор);
		
	КонецЕсли;
	
	Запрос.УстановитьПараметр("ИнформацияПоДоговору", ИнформацияПоДоговору);
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/05
// Текст запроса выбора строк печатной формы.
//
//	Параметры:
//	Запрос          - Запрос
//	ТекстыЗапроса	- Массив
//  Регистры 		- Структура - список имен регистров, для которых необходимо получить таблицы.
//
// Возвращаемое значение:
//  - Строка - текст запроса
//
Функция ТекстЗапросаТаблицаРеестрДокументов(Запрос, ТекстыЗапроса, Регистры)
	
	ИмяРегистра = "РеестрДокументов";
	
	Если НЕ ПроведениеДокументов.ТребуетсяТаблицаДляДвижений(ИмяРегистра, Регистры) Тогда
		
		Возврат "";
		
	КонецЕсли;
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	&Ссылка 					КАК Ссылка,
	|	&Период 					КАК ДатаДокументаИБ,
	|	&Номер 						КАК НомерДокументаИБ,
	|	&ИдентификаторМетаданных	КАК ТипСсылки,
	|	&Организация 				КАК Организация,
	|	НЕОПРЕДЕЛЕНО 				КАК ХозяйственнаяОперация,
	|	&Партнер 					КАК Партнер,
	|	&Контрагент 				КАК Контрагент,
	|	&Договор 					КАК Договор,
	|	НЕОПРЕДЕЛЕНО 				КАК НаправлениеДеятельности,
	|	НЕОПРЕДЕЛЕНО 				КАК МестоХранения,
	|	НЕОПРЕДЕЛЕНО 				КАК Подразделение,
	|	&Ответственный 				КАК Ответственный,
	|	&Ответственный 				КАК Автор,
	|	&Комментарий 				КАК Комментарий,
	|	НЕОПРЕДЕЛЕНО 				КАК Валюта,
	|	НЕОПРЕДЕЛЕНО 				КАК Сумма,
	|	НЕОПРЕДЕЛЕНО 				КАК Статус,
	|	&Проведен 					КАК Проведен,
	|	&ПометкаУдаления			КАК ПометкаУдаления,
	|	ЛОЖЬ						КАК ДополнительнаяЗапись,
	|	&ИнформацияПоДоговору		КАК Дополнительно,
	|	НЕОПРЕДЕЛЕНО				КАК ДатаПервичногоДокумента,
	|	ЛОЖЬ						КАК СторноИсправление,
	|	НЕОПРЕДЕЛЕНО				КАК СторнируемыйДокумент,
	|	НЕОПРЕДЕЛЕНО				КАК ИсправляемыйДокумент,
	|	НЕОПРЕДЕЛЕНО				КАК НомерПервичногоДокумента,
	|	НЕОПРЕДЕЛЕНО				КАК Приоритет";
	
	ТекстыЗапроса.Добавить(ТекстЗапроса, ИмяРегистра);
	
	Возврат ТекстЗапроса;
	
КонецФункции // } #wortmann

#КонецОбласти
	
#КонецЕсли
