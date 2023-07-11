﻿
&После ("ДобавитьКомандыПечати")
Процедура гф_ДобавитьКомандыПечати(КомандыПечати)
	// ++ Галфинд ЕсиповАВ 30.12.2022
	ЭтоПартнер = ПраваПользователяПовтИсп.ЭтоПартнер();
	
	Если НЕ ЭтоПартнер Тогда
		
		КомандаПечати = КомандыПечати.Добавить();
		КомандаПечати.Идентификатор = "гф_СписокКодовМаркировки";
		КомандаПечати.Представление = НСтр("ru = 'Список кодов номенклатуры';
											|en = 'Item code list'");
		КомандаПечати.ПроверкаПроведенияПередПечатью = Истина;
		КомандаПечати.Порядок = 10;
		//++ Галфинд ЕсиповАВ 30.03.2023
		КомандаПечати = КомандыПечати.Добавить();
		КомандаПечати.Идентификатор = "гф_РасходнаяНакладнаяКороб";
		КомандаПечати.Представление = НСтр("ru = 'Расходная накладная короб';
											|en = 'Consumable waybill box'");
		КомандаПечати.ПроверкаПроведенияПередПечатью = Истина;
		КомандаПечати.Порядок = 10;
		//-- Галфинд ЕсиповАВ 30.03.2023
		
	КонецЕсли;
	// -- Галфинд ЕсиповАВ 30.12.2022
КонецПроцедуры

&После ("Печать")
Процедура гф_Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	// ++ Галфинд ЕсиповАВ 30.12.2022
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "гф_СписокКодовМаркировки") Тогда
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"гф_СписокКодовМаркировки",
		НСтр("ru = 'Список кодов номенклатуры';
		|en = 'Item code list'"),
			гф_РасходныйОрдер.СформироватьПечатнуюФормуСписокКМ(МассивОбъектов, ОбъектыПечати),
			,
			"Документ.РеализацияТоваровУслуг.гф_СписокКодовМаркировки");
	КонецЕсли;
	//++ Галфинд ЕсиповАВ 30.03.2023
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "гф_РасходнаяНакладнаяКороб") Тогда
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"гф_РасходнаяНакладнаяКороб",
		НСтр("ru = 'Расходная накладная короб';
		|en = 'Consumable waybill box'"),
			СформироватьПечатнуюФормуРасходнаяНакладнаяКороб(МассивОбъектов, ОбъектыПечати),
			,
			"Документ.РеализацияТоваровУслуг.гф_РасходнаяНакладнаяКороб");
	КонецЕсли;
	//-- Галфинд ЕсиповАВ 30.03.2023
	// -- Галфинд ЕсиповАВ 30.12.2022
КонецПроцедуры

&ИзменениеИКонтроль("СформироватьКомплектПечатныхФорм")
Функция гф_СформироватьКомплектПечатныхФорм(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати)

	Перем АдресКомплектаПечатныхФорм;

	Если ТипЗнч(ПараметрыПечати) = Тип("Структура") И ПараметрыПечати.Свойство("АдресКомплектаПечатныхФорм", АдресКомплектаПечатныхФорм) Тогда

		КомплектПечатныхФорм = ПолучитьИзВременногоХранилища(АдресКомплектаПечатныхФорм);

	Иначе

		КомплектПечатныхФорм = РегистрыСведений.НастройкиПечатиОбъектов.КомплектПечатныхФорм(
		Метаданные.Документы.РеализацияТоваровУслуг.ПолноеИмя(),
		МассивОбъектов, Неопределено);

	КонецЕсли;

	Если КомплектПечатныхФорм = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	РеализацияТоваровУслугЛокализация.СформироватьКомплектПечатныхФорм(МассивОбъектов,
	ПараметрыПечати,
	КоллекцияПечатныхФорм,
	ОбъектыПечати,
	КомплектПечатныхФорм);

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"Накладная");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		СформироватьПечатнуюФормуНакладная(КомплектПечати.Объекты, ОбъектыПечати, Неопределено));
	КонецЦикла;
	#Вставка
	// ++ Галфинд ЕсиповАВ 30.12.2022
	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	гф_РасходныйОрдер);
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		гф_РасходныйОрдер.СформироватьПечатнуюФормуСписокКМ(КомплектПечати.Объекты, ОбъектыПечати, Неопределено));
	КонецЦикла;
	// -- Галфинд ЕсиповАВ 30.12.2022
	//++ Галфинд ЕсиповАВ 30.03.2023
	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"РасходнаяНакладнаяКороб");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		СформироватьПечатнуюФормуРасходнаяНакладнаяКороб(КомплектПечати.Объекты, ОбъектыПечати));
	КонецЦикла;
	//-- Галфинд ЕсиповАВ 30.03.2023
	#КонецВставки

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"НакладнаяБезСкидок");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		СформироватьПечатнуюФормуНакладная(КомплектПечати.Объекты, ОбъектыПечати, Новый Структура("ОтображатьСкидки", Ложь)));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"РасходнаяНакладная");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		СформироватьПечатнуюФормуРасходнаяНакладная(КомплектПечати.Объекты, ОбъектыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"Акт");
	ПараметрыПечати.Удалить("ОтображатьСкидки");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		СтруктураТипов = Новый Соответствие;
		СтруктураТипов.Вставить("Документ.РеализацияТоваровУслуг", КомплектПечати.Объекты);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Обработки.ПечатьАктОбОказанииУслуг.СформироватьПечатнуюФормуАктОбОказанииУслуг(СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"АктБезСкидок");
	ПараметрыПечати.Вставить("ОтображатьСкидки", Ложь);
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		СтруктураТипов = Новый Соответствие;
		СтруктураТипов.Вставить("Документ.РеализацияТоваровУслуг", КомплектПечати.Объекты);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Обработки.ПечатьАктОбОказанииУслуг.СформироватьПечатнуюФормуАктОбОказанииУслуг(СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"СчетНаОплату");
	ПараметрыПечати.Удалить("ОтображатьСкидки");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		СтруктураТипов = Новый Соответствие;
		СтруктураТипов.Вставить("Документ.РеализацияТоваровУслуг", КомплектПечати.Объекты);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Обработки.ПечатьСчетовНаОплату.СформироватьПечатнуюФормуСчетНаОплату(СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"СчетНаОплатуБезСкидок");
	ПараметрыПечати.Вставить("ОтображатьСкидки", Ложь);
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		СтруктураТипов = Новый Соответствие;
		СтруктураТипов.Вставить("Документ.РеализацияТоваровУслуг", КомплектПечати.Объекты);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Обработки.ПечатьСчетовНаОплату.СформироватьПечатнуюФормуСчетНаОплату(СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"СчетНаОплатуСФаксимиле");
	ПараметрыПечати.Удалить("ОтображатьСкидки");
	ПараметрыПечати.Вставить("ОтображатьФаксимиле", Истина);
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		СтруктураТипов = Новый Соответствие;
		СтруктураТипов.Вставить("Документ.РеализацияТоваровУслуг", КомплектПечати.Объекты);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Обработки.ПечатьСчетовНаОплату.СформироватьПечатнуюФормуСчетНаОплату(СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"СчетНаОплатуСФаксимилеБезСкидок");
	ПараметрыПечати.Вставить("ОтображатьСкидки", Ложь);
	ПараметрыПечати.Вставить("ОтображатьФаксимиле", Истина);
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		СтруктураТипов = Новый Соответствие;
		СтруктураТипов.Вставить("Документ.РеализацияТоваровУслуг", КомплектПечати.Объекты);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Обработки.ПечатьСчетовНаОплату.СформироватьПечатнуюФормуСчетНаОплату(СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"InvoiceInt");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		СтруктураТипов = Новый Соответствие;
		СтруктураТипов.Вставить("Документ.РеализацияТоваровУслуг", КомплектПечати.Объекты);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Обработки.ПечатьСчетовНаОплату.СформироватьПечатнуюФормуInvoice(СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"ProformaInvoice");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		СтруктураТипов = Новый Соответствие;
		СтруктураТипов.Вставить("Документ.РеализацияТоваровУслуг", КомплектПечати.Объекты);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Обработки.ПечатьСчетовНаОплату.СформироватьПечатнуюФормуProformaInvoice(СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"ЗаданиеНаОтборРазмещениеТовара");

	ПараметрыПечати.Вставить("ТипЗадания", "ЗаданиеНаОтбор");

	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		СтруктураТипов = Новый Соответствие;
		СтруктураТипов.Вставить("Документ.РеализацияТоваровУслуг", КомплектПечати.Объекты);

		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Обработки.ПечатьЗаданияНаОтборРазмещениеТоваров.СформироватьЗаданиеНаОтборРазмещениеТовара(СтруктураТипов,
		ОбъектыПечати,
		ПараметрыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"СертификатыНоменклатурыРеестр");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Справочники.СертификатыНоменклатуры.СформироватьПечатнуюФормуРеестрСертификатовНоменклатуры(КомплектПечати.Объекты, ОбъектыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"СертификатыНоменклатурыИзображенияИзДокументов");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Справочники.СертификатыНоменклатуры.СформироватьПечатнуюФормуИзображенияСертификатовИзДокументов(КомплектПечати.Объекты, ОбъектыПечати));
	КонецЦикла;

	КомплектыПечатиПоОбъектам = РегистрыСведений.НастройкиПечатиОбъектов.КомплектыПечатиПоОбъектам(КоллекцияПечатныхФорм,
	КомплектПечатныхФорм,
	МассивОбъектов,
	"СертификатыНоменклатурыИзображенияИзДокументовБезДублей");
	Для Каждого КомплектПечати Из КомплектыПечатиПоОбъектам Цикл
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		КомплектПечати.Имя,
		КомплектПечати.Представление,
		Справочники.СертификатыНоменклатуры.СформироватьПечатнуюФормуИзображенияСертификатовИзДокументовБезДублей(КомплектПечати.Объекты, ОбъектыПечати));
	КонецЦикла;


	РегистрыСведений.НастройкиПечатиОбъектов.СформироватьКомплектВнешнихПечатныхФорм(
	"Документ.РеализацияТоваровУслуг",
	МассивОбъектов,
	ПараметрыПечати,
	КоллекцияПечатныхФорм,
	ОбъектыПечати);

КонецФункции

Функция СформироватьПечатнуюФормуРасходнаяНакладнаяКороб(МассивОбъектов, ОбъектыПечати)
	
	ТабДок = Новый ТабличныйДокумент;
	
	МакетОбработки = Документы.РеализацияТоваровУслуг.ПолучитьМакет("гф_РасходнаяНакладнаяКороб");
	
	ОбластьШапки = МакетОбработки.ПолучитьОбласть("Шапка");
	ОбластьТЧ = МакетОбработки.ПолучитьОбласть("ТЧ");
	ОбластьИтого = МакетОбработки.ПолучитьОбласть("Итого");
	ОбластьТекст = МакетОбработки.ПолучитьОбласть("Текст");
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	
	"ВЫБРАТЬ
	|	РеализацияТоваровУслуг.Ссылка КАК Ссылка,
	|	РеализацияТоваровУслуг.Номер КАК Номер,
	|	РеализацияТоваровУслуг.Дата КАК Дата,
	|	РеализацияТоваровУслуг.гф_ТоварыВКоробах.(
	|		Ссылка КАК Ссылка,
	|		НомерСтроки КАК НомерСтроки,
	|		УпаковочныйЛист КАК УпаковочныйЛист,
	|		Артикул КАК Артикул,
	|		КоличествоПар КАК КоличествоПар,
	|		Коэффициент КАК Коэффициент,
	|		ЦенаКороба КАК ЦенаКороба,
	|		НДС КАК НДС
	|	) КАК гф_ТоварыВКоробах,
	|	РеализацияТоваровУслуг.Организация КАК Организация,
	|	РеализацияТоваровУслуг.Контрагент КАК Контрагент
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|ГДЕ
	|	РеализацияТоваровУслуг.Ссылка В(&МассивОбъектов)";
	
	Запрос.Параметры.Вставить("МассивОбъектов", МассивОбъектов);
	
	Таб = Запрос.Выполнить().Выгрузить();
	
	//Таб[0].Номер
	НомерБезПрефикса = Прав(Таб[0].Номер,6);
	НомерБезНулей = НомерБезПрефикса;
	Пока Найти(НомерБезНулей,"0") = 1 Цикл
		//НомерБезНулей = Прав(НомерБезНулей, СтрДлина(НомерБезНулей)-1); //удаляет лидирующие нули
		НомерБезНулей = Сред(НомерБезНулей,2);
	КонецЦикла;
	
	ДатаЗаголовка = Формат(Таб[0].Дата, "ДЛФ=DD");
	ОбластьШапки.Параметры.Заголовок  = "Расходная накладная " + НомерБезНулей + " от " + ДатаЗаголовка;
	ОбластьШапки.Параметры.Поставщик  = Таб[0].Организация.НаименованиеПолное;
	ОбластьШапки.Параметры.Покупатель = Таб[0].Контрагент.НаименованиеПолное;
	ТабДок.Вывести(ОбластьШапки);
	
	Сч = 0;
	ИтогоСум = 0;
	СуммаНДССум = 0;
	ИтогоТекст = 0;
	
	Для Каждого Стр Из Таб Цикл
		
		Для Каждого СтрокаТовараВКоробах Из Стр.гф_ТоварыВКоробах Цикл
		
		Сч = Сч + 1;
		ОбластьТЧ.Параметры.Номер      = Сч;
		ОбластьТЧ.Параметры.Артикул    = СтрокаТовараВКоробах.Артикул;
		ОбластьТЧ.Параметры.Ростовка   = СтрокаТовараВКоробах.УпаковочныйЛист.гф_Комплектация.Характеристика;
		
		СтрокаСоСкобками = СтрокаТовараВКоробах.УпаковочныйЛист.Код;
		СтрокаБезЛевойСкобоки = СтрЗаменить(СтрокаСоСкобками,"(","");
		СтрокаБезПравойкобоки = СтрЗаменить(СтрокаСоСкобками,")","");
		
		НаименованиеПолноеКолиечство = СтрДлина(СтрокаТовараВКоробах.УпаковочныйЛист.гф_Комплектация.Владелец.НаименованиеПолное);
		НаименованиеКодаКоличество = СтрДлина(СтрокаТовараВКоробах.УпаковочныйЛист.гф_Комплектация.Владелец.КоллекцияНоменклатуры.Код);
		НаименованиеТовараКоличество = Лев(СтрокаТовараВКоробах.УпаковочныйЛист.гф_Комплектация.Владелец.НаименованиеПолное,НаименованиеПолноеКолиечство - НаименованиеКодаКоличество);
		
		ОбластьТЧ.Параметры.Товар      = НаименованиеТовараКоличество + "
		|" + "(" + СтрокаБезПравойкобоки + "," + "
		|" + СтрокаТовараВКоробах.УпаковочныйЛист.гф_Агрегация.гф_НомерГТД + "," + "
		|" + СтрокаТовараВКоробах.УпаковочныйЛист.гф_Агрегация.гф_НомерГТД.СтранаПроисхождения + "," + "
		|" + СтрокаБезПравойкобоки + ")";
		ОбластьТЧ.Параметры.Мест       = СтрокаТовараВКоробах.Коэффициент;
		ОбластьТЧ.Параметры.Количество = 1;
		ОбластьТЧ.Параметры.Пар        = СтрокаТовараВКоробах.КоличествоПар;
		ОбластьТЧ.Параметры.Цена       = СтрокаТовараВКоробах.ЦенаКороба + СтрокаТовараВКоробах.НДС;
		ОбластьТЧ.Параметры.Сумма      = (СтрокаТовараВКоробах.ЦенаКороба + СтрокаТовараВКоробах.НДС); 
		ОбластьТЧ.Параметры.ГДТ        = СтрокаТовараВКоробах.УпаковочныйЛист.гф_Агрегация.гф_НомерГТД.Код + "," + "
		|" + СтрокаТовараВКоробах.УпаковочныйЛист.гф_Агрегация.гф_НомерГТД.СтранаПроисхождения;
		
		ИтогоТекст = ИтогоТекст + (СтрокаТовараВКоробах.ЦенаКороба + СтрокаТовараВКоробах.НДС);
		ИтогоСум = ИтогоСум + СтрокаТовараВКоробах.ЦенаКороба;
		СуммаНДССум = СуммаНДССум + СтрокаТовараВКоробах.НДС;
		
		ТабДок.Вывести(ОбластьТЧ);
		
		КонецЦикла;
		
	КонецЦикла;
	
	ОбластьИтого.Параметры.Итого = ИтогоСум;
	ОбластьИтого.Параметры.СуммаНДС = СуммаНДССум;
	ТабДок.Вывести(ОбластьИтого);
	
	ОбластьТекст.Параметры.Всего = "Всего наименований " + Сч + ", на сумму " + ИтогоТекст + " руб.";
	ОбластьТекст.Параметры.ВсегоТекст = ЧислоПрописью(ИтогоТекст);
	ТабДок.Вывести(ОбластьТекст);
	
	Возврат ТабДок;
КонецФункции	
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область Печать

#КонецОбласти

#КонецЕсли