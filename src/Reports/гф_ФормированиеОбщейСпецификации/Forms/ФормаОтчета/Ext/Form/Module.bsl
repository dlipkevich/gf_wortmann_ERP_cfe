﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка) 
	
	Отчет.Вид = "РеализацииПокупателей";
	// ++ СадомцевСА 30.09.2022
	Отчет.ФормироватьВПарах = Истина;
	Отчет.НачалоПериода = НачалоМесяца(ТекущаяДатаСеанса());
	Отчет.КонецПериода = КонецДня(ТекущаяДатаСеанса());
	Отчет.ДопРеквизитТоварыВКоробах = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("ИдентификаторДляФормул", "гф_СкладыТоварыВКоробах");
	// -- СадомцевСА 30.09.2022
	УстановитьВидимостьРеквизитов();
	УстановитьПараметрыСКД();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьВариантОтчета()
	
	Если Отчет.ФормироватьВПарах Тогда
		  УстановитьТекущийВариант("ВПарах");
	Иначе
		 УстановитьТекущийВариант("ВКоробах");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНастройкиОтбора() 
	
	//ОбъектОтчет = РеквизитФормыВЗначение("Отчет");

	//СхемаКомпоновки = ОбъектОтчет.ПолучитьМакет("СхемаКомпановкиОтборНоменклатуры");
	//
	//Отчет.КомпоновщикОтбораНоменклатуры.Инициализировать(новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновки));
	////Отчет.КомпоновщикОтбораНоменклатуры.ЗагрузитьПользовательскиеНастройки(.ПолучитьНастройки()
	//Отчет.КомпоновщикОтбораНоменклатуры.ЗагрузитьНастройки(СхемаКомпоновки.НастройкиПоУмолчанию);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокВыбораВидаОтчета()
	
	//СписокВыбора = Новый СписокЗначений;
	//СписокВыбора.Добавить("РеализацииПокупателей","Реализации покупателей");
	//СписокВыбора.Добавить("ЗаказыКлиентов","Заказы клиентов");
	//СписокВыбора.Добавить("ПриобретениеТоваровИУслуг","Приобретение товаров и услуг");
	//СписокВыбора.Добавить("ВнутренниеЗаказы","Внутренние заказы");
	//СписокВыбора.Добавить("СвободныеОстатки","Свободные остатки");
	//СписокВыбора.Добавить("ФактическиеОстатки","Фактические остатки"); 
	//СписокВыбора.Добавить("Ассортимент","Ассортимент");
	//СписокВыбора.Добавить("Перемещения","Перемещения");
	//
	//Элементы.Вид.СписокВыбора.ЗагрузитьЗначения(СписокВыбора.ВыгрузитьЗначения());
		
КонецПроцедуры	

&НаКлиенте
Процедура ВидПриИзменении(Элемент)  
	
	УстановитьВидимостьРеквизитов();
	УстановитьПараметрыСКД(); 
	//Отчет.КомпоновщикНастроек.Восстановить();
	
	Отчет.ТаблицаДокументы.Очистить();
		 
КонецПроцедуры

&НаКлиенте
Процедура ЦенаСоСкидкойПриИзменении(Элемент)
	УстановитьПараметрыСКДВМодуле();
КонецПроцедуры

&НаСервере
Процедура УстановитьПараметрыСКД()
	
	
	
	ОтчетОбъект = РеквизитФормыВЗначение("Отчет");
	//Если Отчет.Вид = "Ассортимент" Тогда
	//	СхемаКомпоновкиДанных = ОтчетОбъект.ПолучитьМакет("СхемаКомпоновкиДанныхАссортимент"); 
	//	НстройкиСКД = ?(Отчет.ФормироватьВПарах,СхемаКомпоновкиДанных.ВариантыНастроек.ВПарах.Настройки,СхемаКомпоновкиДанных.ВариантыНастроек.ВКоробах.Настройки);
	//	//НстройкиСКД = СхемаКомпоновкиДанных.ВариантыНастроек.ВПарах.Настройки;
	//Иначе
	//	СхемаКомпоновкиДанных = ОтчетОбъект.ПолучитьМакет("_ОсновнаяСхемаКомпоновкиДанных");
	//КонецЕсли;
	Если Отчет.Вид = "ВнутренниеЗаказы" Тогда
		ИмяСКД = "СхемаВнутренниеЗаказыВПарах";
	Иначе	
		ИмяСКД = "Схема"+Отчет.Вид+?(Отчет.ФормироватьВПарах,"ВПарах","ВКоробах");
	КонецЕсли;
	СхемаКомпоновкиДанных = ОтчетОбъект.ПолучитьМакет(ИмяСКД);
	
	Отчет.АдресСхемы = ПоместитьВоВременноеХранилище(СхемаКомпоновкиДанных, УникальныйИдентификатор);
	//Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы.Очистить();	
	Отчет.КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(Отчет.АдресСхемы));
    Отчет.КомпоновщикНастроек.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	
	//Отчет.КомпоновщикНастроек..ЗагрузитьПользовательскиеНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	//Отчет.КомпоновщикОтбораНоменклатуры.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	//Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.
	//Отчет.КомпоновщикНастроек.Восстановить(СпособВосстановленияНастроекКомпоновкиДанных..ПроверятьДоступность);
	//ХранилищеПользовательскихНастроекОтчетов.Удалить( 
	//Отчет.КомпоновщикНастроек.Восстановить();
	ОтчетОбъект.УстановитьПараметрыСКД();	
КонецПроцедуры	

&НаСервере
Процедура УстановитьПараметрыСКДВМодуле()
	ОтчетОбъект = РеквизитФормыВЗначение("Отчет");
	ОтчетОбъект.УстановитьПараметрыСКД();
	Отчет.КомпоновщикНастроек.Восстановить();
КонецПроцедуры	

&НаСервере
Процедура УстановитьВидимостьРеквизитов()
	
	Элементы.КонецПериода.АвтоОтметкаНезаполненного = Ложь;
	Элементы.СкладПолучатель.АвтоОтметкаНезаполненного = Ложь;
	Элементы.ЦенаСоСкидкой.АвтоОтметкаНезаполненного = Ложь;
	Элементы.ДатаОстатков.АвтоОтметкаНезаполненного = Ложь;
	// ++ СадомцевСА 09.02.2023 Добавил строку
	Элементы.Организация.Видимость = Истина;
		
	Если Отчет.Вид = "РеализацииПокупателей" Тогда
		Элементы.ФормироватьВПарах.Видимость = Истина;
		Элементы.НачалоПериода.Видимость = Истина;
		Элементы.КонецПериода.Видимость = Истина;
		Элементы.Контрагент.Видимость = Истина;
		Элементы.ДоговорКонтрагента.Видимость = Истина; 
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Ложь;
		Элементы.ДатаОстатков.Видимость = Ложь;
		Элементы.ЦенаСоСкидкой.Видимость = Ложь;
		Элементы.КомпоновщикОтбораНоменклатурыНастройкиОтбор.Видимость = Ложь;
		
		Элементы.ТаблицаДокументы.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыПометка.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДокумент.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыКонтрагент.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДоговорКонтрагента.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладОтправитель.Видимость = Ложь;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладПолучатель.Видимость = Ложь;
		
	ИначеЕсли Отчет.Вид = "ЗаказыКлиентов" Тогда
		Элементы.ФормироватьВПарах.Видимость = Истина;
		Элементы.НачалоПериода.Видимость = Истина;
		Элементы.КонецПериода.Видимость = Истина;
		Элементы.Контрагент.Видимость = Истина;
		Элементы.ДоговорКонтрагента.Видимость = Истина;
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Ложь;
		Элементы.ДатаОстатков.Видимость = Ложь;
		Элементы.ЦенаСоСкидкой.Видимость = Ложь;
		Элементы.КомпоновщикОтбораНоменклатурыНастройкиОтбор.Видимость = Ложь;
		
		Элементы.ТаблицаДокументы.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыПометка.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДокумент.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыКонтрагент.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДоговорКонтрагента.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладОтправитель.Видимость = Ложь;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладПолучатель.Видимость = Ложь;
	// ++ Галфинд ВолковЕВ 21.04.2023
	//ИначеЕсли Отчет.Вид = "ПриобретениеТоваровИУслуг"
	//		ИЛИ  Отчет.Вид = "Перемещения" Тогда
	ИначеЕсли Отчет.Вид = "ПриобретениеТоваровИУслуг" Тогда
	// -- Галфинд ВолковЕВ 18.04.2023
		Элементы.ФормироватьВПарах.Видимость = Истина;
		Элементы.НачалоПериода.Видимость = Истина;
		Элементы.КонецПериода.Видимость = Истина;
		Элементы.Контрагент.Видимость = Истина;
		Элементы.ДоговорКонтрагента.Видимость = Истина;
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Ложь;
		Элементы.ДатаОстатков.Видимость = Ложь; 
		Элементы.ЦенаСоСкидкой.Видимость = Ложь;
		Элементы.КомпоновщикОтбораНоменклатурыНастройкиОтбор.Видимость = Ложь;
		Элементы.ТаблицаДокументы.Видимость = Истина;
		
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыПометка.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДокумент.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыКонтрагент.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДоговорКонтрагента.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладОтправитель.Видимость = Ложь;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладПолучатель.Видимость = Ложь;
	// ++ Галфинд ВолковЕВ 21.04.2023
	ИначеЕсли Отчет.Вид = "Перемещения" Тогда
		Элементы.ФормироватьВПарах.Видимость = Истина;
		Элементы.НачалоПериода.Видимость = Истина;
		Элементы.КонецПериода.Видимость = Истина;
		Элементы.Контрагент.Видимость = Ложь;
		Элементы.ДоговорКонтрагента.Видимость = Ложь;
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Ложь;
		Элементы.ДатаОстатков.Видимость = Ложь; 
		Элементы.ЦенаСоСкидкой.Видимость = Ложь;
		Элементы.КомпоновщикОтбораНоменклатурыНастройкиОтбор.Видимость = Ложь;
		Элементы.ТаблицаДокументы.Видимость = Истина;
		
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыПометка.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДокумент.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыКонтрагент.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДоговорКонтрагента.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладОтправитель.Видимость = Ложь;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладПолучатель.Видимость = Ложь;
	// -- Галфинд ВолковЕВ 18.04.2023
	
	ИначеЕсли Отчет.Вид = "ВнутренниеЗаказы" Тогда
		
		Элементы.ФормироватьВПарах.Видимость = Ложь;
		
		Отчет.ФормироватьВПарах = Истина;
		
		Элементы.НачалоПериода.Видимость = Истина;
		Элементы.КонецПериода.Видимость = Истина;
		// ++ Галфинд ВолковЕВ 18.04.2023
		//Элементы.Контрагент.Видимость = Истина;
		Элементы.Контрагент.Видимость = Ложь;
		// -- Галфинд ВолковЕВ 18.04.2023
		Элементы.ДоговорКонтрагента.Видимость = Ложь;
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Ложь;
		Элементы.ДатаОстатков.Видимость = Ложь;
		Элементы.ЦенаСоСкидкой.Видимость = Ложь;
		Элементы.КомпоновщикОтбораНоменклатурыНастройкиОтбор.Видимость = Ложь;
		Элементы.ТаблицаДокументы.Видимость = Истина;
		
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыПометка.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДокумент.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыКонтрагент.Видимость = Ложь;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДоговорКонтрагента.Видимость = Ложь;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладОтправитель.Видимость = Ложь;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладПолучатель.Видимость = Ложь;
		
	ИначеЕсли Отчет.Вид = "СвободныеОстатки" Тогда
		Элементы.ФормироватьВПарах.Видимость = Истина;
		Элементы.НачалоПериода.Видимость = Ложь;
		Элементы.КонецПериода.Видимость = Истина;
		Элементы.Контрагент.Видимость = Ложь;
		Элементы.ДоговорКонтрагента.Видимость = Ложь;
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Истина;
		Элементы.СкладПолучатель.Заголовок = "Склад";
		Элементы.ДатаОстатков.Видимость = Ложь;
		Элементы.ЦенаСоСкидкой.Видимость = Истина;
		
		Элементы.КонецПериода.АвтоОтметкаНезаполненного = Истина;
		Элементы.СкладПолучатель.АвтоОтметкаНезаполненного = Истина;
		Элементы.ЦенаСоСкидкой.АвтоОтметкаНезаполненного = Истина;
		
		Элементы.ТаблицаДокументы.Видимость = Ложь; 
		Элементы.КомпоновщикОтбораНоменклатурыНастройкиОтбор.Видимость = Ложь;
		//Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыПометка.Видимость = Истина;
		//Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДокумент.Видимость = Истина;
		//Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыКонтрагент.Видимость = Ложь;
		//Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДоговорКонтрагента.Видимость = Ложь;
		//Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладОтправитель.Видимость = Ложь;
		//Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладПолучатель.Видимость = Ложь;
		
	ИначеЕсли Отчет.Вид = "ФактическиеОстатки" Тогда
		
		Элементы.ФормироватьВПарах.Видимость = Истина;
		Элементы.НачалоПериода.Видимость = Ложь;
		Элементы.КонецПериода.Видимость = Истина;
		Элементы.КонецПериода.АвтоОтметкаНезаполненного = Истина;
		Элементы.Контрагент.Видимость = Ложь;
		Элементы.ДоговорКонтрагента.Видимость = Ложь;
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Истина;
		Элементы.СкладПолучатель.Заголовок = "Склад";
		Элементы.СкладПолучатель.АвтоОтметкаНезаполненного = Истина;
		Элементы.ДатаОстатков.Видимость = Ложь;
		Элементы.ЦенаСоСкидкой.Видимость = Истина;
		Элементы.ЦенаСоСкидкой.АвтоОтметкаНезаполненного = Истина;
		Элементы.ТаблицаДокументы.Видимость = Ложь;
		Элементы.КомпоновщикОтбораНоменклатурыНастройкиОтбор.Видимость = Ложь;
		
	ИначеЕсли Отчет.Вид = "Ассортимент" Тогда
		
		Элементы.ФормироватьВПарах.Видимость = Истина;
		Элементы.НачалоПериода.Видимость = Ложь;
		Элементы.КонецПериода.Видимость = Ложь;
		Элементы.Контрагент.Видимость = Ложь;
		Элементы.ДоговорКонтрагента.Видимость = Ложь;
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Ложь;
		// ++ СадомцевСА 09.02.2023 Раскомментарил строку
		Элементы.КомпоновщикОтбораНоменклатурыНастройкиОтбор.Видимость = Истина;
		// ++ СадомцевСА 09.02.2023 Добавил строку
		Элементы.Организация.Видимость = Ложь;
		
		Элементы.ДатаОстатков.Видимость = Ложь;
		Элементы.ЦенаСоСкидкой.Видимость = Ложь;
		Элементы.ТаблицаДокументы.Видимость = Ложь;
		
		УстановитьТекущийВариант(?(Отчет.ФормироватьВПарах,"ВПарах","ВКоробах"));
		
		ЗаполнитьНастройкиОтбора();
	Иначе
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Отметить(Команда)
	
	Для каждого Строка из Отчет.ТаблицаДокументы Цикл
			Строка.Пометка = Истина;		
	КонецЦикла;	
		
КонецПроцедуры 

&НаКлиенте
Процедура СнятьОтметку(Команда) 
	
	Для каждого Строка из Отчет.ТаблицаДокументы Цикл
			Строка.Пометка = Ложь;		
	КонецЦикла;
		
КонецПроцедуры

&НаСервере
Процедура ПолучитьДокументыНаСервере()
	
	Отчет.ТаблицаДокументы.Очистить();
	
	Если Отчет.Вид = "РеализацииПокупателей" Тогда
		 ЗаполнитьДокументы_РеализацииПокупателей();
	ИначеЕсли Отчет.Вид = "ЗаказыКлиентов" Тогда	
		 ЗаполнитьДокументы_ЗаказыКлиентов();
	ИначеЕсли Отчет.Вид = "ПриобретениеТоваровИУслуг" Тогда	
		 ЗаполнитьДокументы_ПриобретениеТоваровИУслуг();
	ИначеЕсли Отчет.Вид = "Перемещения" Тогда
		 ЗаполнитьДокументы_Перемещения();
	//ИначеЕсли Отчет.Вид = "СвободныеОстатки" Тогда	
		
	ИначеЕсли Отчет.Вид = "ВнутренниеЗаказы" Тогда	
		 ЗаполнитьДокументы_ВнутренниеЗаказы();
	Иначе 
		 Возврат;	 
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДокументы_РеализацииПокупателей()
	
	Запрос = новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	РеализацияТоваровУслуг.Ссылка КАК Документ,
	|	РеализацияТоваровУслуг.Контрагент КАК Контрагент,
	|	РеализацияТоваровУслуг.Договор КАК ДоговорКонтрагента
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|ГДЕ
	|	РеализацияТоваровУслуг.Дата МЕЖДУ &НачалоПериода И &КонецПериода
	|	И РеализацияТоваровУслуг.Проведен = ИСТИНА
	|	И ВЫБОР
	|			КОГДА &ОтборПоКонтрагенту
	|				ТОГДА РеализацияТоваровУслуг.Контрагент = &Контрагент
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ОтборПоДоговору
	|				ТОГДА РеализацияТоваровУслуг.Договор = &ДоговорКонтрагента
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И РеализацияТоваровУслуг.Организация = &Организация";
	
	Если Не ЗначениеЗаполнено(Отчет.НачалоПериода) И Не ЗначениеЗаполнено(Отчет.КонецПериода) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "РеализацияТоваровУслуг.Дата МЕЖДУ &НачалоПериода И &КонецПериода",  "ИСТИНА");
	КонецЕсли;
	
	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(Отчет.НачалоПериода));
	// ++ Галфинд ВолковЕВ 18.04.2023
	//Запрос.УстановитьПараметр("КонецПериода",НачалоДня(Отчет.КонецПериода));
	Запрос.УстановитьПараметр("КонецПериода",КонецДня(Отчет.КонецПериода));
	// -- Галфинд ВолковЕВ 18.04.2023
	Запрос.УстановитьПараметр("ОтборПоКонтрагенту",ЗначениеЗаполнено(Отчет.Контрагент));
	Запрос.УстановитьПараметр("ОтборПоДоговору",ЗначениеЗаполнено(Отчет.ДоговорКонтрагента));
	Запрос.УстановитьПараметр("Контрагент",Отчет.Контрагент);
	Запрос.УстановитьПараметр("ДоговорКонтрагента",Отчет.ДоговорКонтрагента);
	Запрос.УстановитьПараметр("Организация",Отчет.Организация);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		 НоваяСтрока = Отчет.ТаблицаДокументы.Добавить();
		 ЗаполнитьЗначенияСвойств(НоваяСтрока,Выборка);
	КонецЦикла;	
	
КонецПроцедуры	

&НаСервере
Процедура ЗаполнитьДокументы_ЗаказыКлиентов() 
		
	Запрос = новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ЗаказКлиента.Ссылка КАК Документ,
	|	ЗаказКлиента.Контрагент КАК Контрагент,
	|	ЗаказКлиента.Договор КАК ДоговорКонтрагента
	|ИЗ
	|	Документ.ЗаказКлиента КАК ЗаказКлиента
	|ГДЕ
	|	ЗаказКлиента.Дата МЕЖДУ &НачалоПериода И &КонецПериода
	|	И ЗаказКлиента.Проведен = ИСТИНА
	|	И ВЫБОР
	|			КОГДА &ОтборПоКонтрагенту
	|				ТОГДА ЗаказКлиента.Контрагент = &Контрагент
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ОтборПоДоговору
	|				ТОГДА ЗаказКлиента.Договор = &ДоговорКонтрагента
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ЗаказКлиента.Организация = &Организация";
	// ++ СадомцевСА 30.09.2022
	Если Не ЗначениеЗаполнено(Отчет.НачалоПериода) И Не ЗначениеЗаполнено(Отчет.КонецПериода) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЗаказКлиента.Дата МЕЖДУ &НачалоПериода И &КонецПериода",  "ИСТИНА");
	КонецЕсли;
	// -- СадомцевСА 30.09.2022
	
	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(Отчет.НачалоПериода));
	// ++ Галфинд ВолковЕВ 18.04.2023
	//Запрос.УстановитьПараметр("КонецПериода",НачалоДня(Отчет.КонецПериода));
	Запрос.УстановитьПараметр("КонецПериода",КонецДня(Отчет.КонецПериода));
	// -- Галфинд ВолковЕВ 18.04.2023
	Запрос.УстановитьПараметр("ОтборПоКонтрагенту",ЗначениеЗаполнено(Отчет.Контрагент));
	Запрос.УстановитьПараметр("ОтборПоДоговору",ЗначениеЗаполнено(Отчет.ДоговорКонтрагента));
	Запрос.УстановитьПараметр("Контрагент",Отчет.Контрагент);
	Запрос.УстановитьПараметр("ДоговорКонтрагента",Отчет.ДоговорКонтрагента);
	Запрос.УстановитьПараметр("Организация",Отчет.Организация);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		 НоваяСтрока = Отчет.ТаблицаДокументы.Добавить();
		 ЗаполнитьЗначенияСвойств(НоваяСтрока,Выборка);
	КонецЦикла;	

КонецПроцедуры  

&НаСервере
Процедура ЗаполнитьДокументы_ПриобретениеТоваровИУслуг()
	
	Запрос = новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ПриобретениеТоваровУслуг.Ссылка КАК Документ,
	|	ПриобретениеТоваровУслуг.Контрагент КАК Контрагент,
	|	ПриобретениеТоваровУслуг.Договор КАК ДоговорКонтрагента
	|ИЗ
	|	Документ.ПриобретениеТоваровУслуг КАК ПриобретениеТоваровУслуг
	|ГДЕ
	|	ПриобретениеТоваровУслуг.Дата МЕЖДУ &НачалоПериода И &КонецПериода
	|	И ПриобретениеТоваровУслуг.Проведен = ИСТИНА
	|	И ВЫБОР
	|			КОГДА &ОтборПоКонтрагенту
	|				ТОГДА ПриобретениеТоваровУслуг.Контрагент = &Контрагент
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ОтборПоДоговору
	|				ТОГДА ПриобретениеТоваровУслуг.Договор = &ДоговорКонтрагента
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ПриобретениеТоваровУслуг.Организация = &Организация";
	
	Если Не ЗначениеЗаполнено(Отчет.НачалоПериода) И Не ЗначениеЗаполнено(Отчет.КонецПериода) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ПриобретениеТоваровУслуг.Дата МЕЖДУ &НачалоПериода И &КонецПериода",  "ИСТИНА");
	КонецЕсли;

	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(Отчет.НачалоПериода));
	// ++ Галфинд ВолковЕВ 18.04.2023
	//Запрос.УстановитьПараметр("КонецПериода",НачалоДня(Отчет.КонецПериода));
	Запрос.УстановитьПараметр("КонецПериода",КонецДня(Отчет.КонецПериода));
	// -- Галфинд ВолковЕВ 18.04.2023
	Запрос.УстановитьПараметр("ОтборПоКонтрагенту",ЗначениеЗаполнено(Отчет.Контрагент));
	Запрос.УстановитьПараметр("Контрагент",Отчет.Контрагент);
	Запрос.УстановитьПараметр("ОтборПоДоговору",ЗначениеЗаполнено(Отчет.ДоговорКонтрагента));
	Запрос.УстановитьПараметр("ДоговорКонтрагента",Отчет.ДоговорКонтрагента);
	Запрос.УстановитьПараметр("Организация",Отчет.Организация);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		 НоваяСтрока = Отчет.ТаблицаДокументы.Добавить();
		 ЗаполнитьЗначенияСвойств(НоваяСтрока,Выборка);
	КонецЦикла;	

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДокументы_Перемещения()
	
	Запрос = новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ПеремещениеТоваров.Ссылка КАК Документ,
	|	ПеремещениеТоваров.СкладОтправитель КАК СкладОтправитель,
	|	ПеремещениеТоваров.СкладПолучатель КАК СкладПолучатель
	|ИЗ
	|	Документ.ПеремещениеТоваров КАК ПеремещениеТоваров
	|ГДЕ
	|	ПеремещениеТоваров.Дата МЕЖДУ &НачалоПериода И &КонецПериода
	|	И ПеремещениеТоваров.Проведен = ИСТИНА
	|	И ВЫБОР
	|			КОГДА &ОтборПоСкладуОтправителя
	|				ТОГДА ПеремещениеТоваров.СкладОтправитель = &СкладОтправитель
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВЫБОР
	|			КОГДА &ОтборПоСкладуПолучателя
	|				ТОГДА ПеремещениеТоваров.СкладПолучатель = &СкладПолучатель
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ПеремещениеТоваров.Организация = &Организация";
	
	Запрос.УстановитьПараметр("НачалоПериода", НачалоДня(Отчет.НачалоПериода));
	// ++ Галфинд ВолковЕВ 18.04.2023
	//Запрос.УстановитьПараметр("КонецПериода", НачалоДня(Отчет.КонецПериода));
	Запрос.УстановитьПараметр("КонецПериода", КонецДня(Отчет.КонецПериода));
	// -- Галфинд ВолковЕВ 18.04.2023
	Запрос.УстановитьПараметр("ОтборПоСкладуОтправителя", ЗначениеЗаполнено(Отчет.СкладОтправитель));
	Запрос.УстановитьПараметр("ОтборПоСкладуПолучателя", ЗначениеЗаполнено(Отчет.СкладПолучатель));
	Запрос.УстановитьПараметр("СкладОтправитель", Отчет.СкладОтправитель);
	Запрос.УстановитьПараметр("СкладПолучатель", Отчет.СкладПолучатель);
	Запрос.УстановитьПараметр("Организация",Отчет.Организация);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		 НоваяСтрока = Отчет.ТаблицаДокументы.Добавить();
		 ЗаполнитьЗначенияСвойств(НоваяСтрока,Выборка);
	КонецЦикла;	

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДокументы_ВнутренниеЗаказы()
	
	Запрос = новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВнутреннееПотреблениеТоваров.Ссылка КАК Документ,
	|	ВнутреннееПотреблениеТоваров.гф_Контрагент КАК Контрагент
	|ИЗ
	|	Документ.ВнутреннееПотребление КАК ВнутреннееПотреблениеТоваров
	|ГДЕ
	|	ВнутреннееПотреблениеТоваров.Дата МЕЖДУ &НачалоПериода И &КонецПериода
	|	И ВнутреннееПотреблениеТоваров.Проведен = ИСТИНА
	|	И ВЫБОР
	|			КОГДА &ОтборПоКонтрагенту
	|				ТОГДА ВнутреннееПотреблениеТоваров.гф_Контрагент = &Контрагент
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВнутреннееПотреблениеТоваров.Организация = &Организация";
	
	Если Не ЗначениеЗаполнено(Отчет.НачалоПериода) И Не ЗначениеЗаполнено(Отчет.КонецПериода) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ВнутреннееПотреблениеТоваров.Дата МЕЖДУ &НачалоПериода И &КонецПериода", "ИСТИНА");
	КонецЕсли;
	
	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(Отчет.НачалоПериода));
	// ++ Галфинд ВолковЕВ 18.04.2023
	//Запрос.УстановитьПараметр("КонецПериода",НачалоДня(Отчет.КонецПериода));
	Запрос.УстановитьПараметр("КонецПериода",КонецДня(Отчет.КонецПериода));
	// -- Галфинд ВолковЕВ 18.04.2023
	Запрос.УстановитьПараметр("ОтборПоКонтрагенту",ЗначениеЗаполнено(Отчет.Контрагент));
	Запрос.УстановитьПараметр("Контрагент",Отчет.Контрагент);	
	Запрос.УстановитьПараметр("Организация",Отчет.Организация);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		 НоваяСтрока = Отчет.ТаблицаДокументы.Добавить();
		 ЗаполнитьЗначенияСвойств(НоваяСтрока,Выборка);
	КонецЦикла;	

КонецПроцедуры

&НаКлиенте
Процедура ПолучитьДокументы(Команда)
	ПроверитьЗаполнение();
	ПолучитьДокументыНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура СкрытьОтборы(Команда)  
	
	Если Элементы.СкрытьОтборы.Заголовок = "Скрыть отборы" Тогда 
		 Элементы.ГруппаОтборы.Видимость = Ложь;
		 Элементы.СкрытьОтборы.Заголовок = "Показать отборы";		
	Иначе
		 Элементы.ГруппаОтборы.Видимость = Истина;
		 Элементы.СкрытьОтборы.Заголовок = "Скрыть отборы"
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьОтчет(Команда)
	
	Режим = РежимДиалогаВыбораФайла.Сохранение; 
	ДиалогСохраненияФайла = Новый ДиалогВыбораФайла(Режим); 
	ДиалогСохраненияФайла.ПолноеИмяФайла = СформироватьИмяФайла(); 
	Фильтр = "Файлы Microsoft Excel(*.xlsx)|*.xlsx";                 
	ДиалогСохраненияФайла.Фильтр = Фильтр; 
	ДиалогСохраненияФайла.МножественныйВыбор = Ложь; 
	ДиалогСохраненияФайла.Заголовок = "Выберите файл"; 
	
	Если ДиалогСохраненияФайла.Выбрать() Тогда 
		ПутьКФайлу = ДиалогСохраненияФайла.ПолноеИмяФайла; 
		 
	КонецЕсли; 
	
КонецПроцедуры

&НаСервере
Функция СформироватьИмяФайла()
	
	Если Отчет.Вид = "Перемещения" ИЛИ Отчет.Вид = "Ассортимент" Тогда
		ИмяФайла = Формат(ТекущаяДатаСеанса(), "ДФ=ггггммдд")+ Отчет.Вид;
	Иначе
		ИмяФайла = Формат(ТекущаяДатаСеанса(), "ДФ=ггггммдд")+ Отчет.Вид+Строка(Отчет.Контрагент)+Строка(Отчет.СкладПолучатель);
	КонецЕсли;	
	Возврат ИмяФайла;
КонецФункции	

&НаКлиенте
Процедура ФормироватьВПарахПриИзменении(Элемент)
	
	УстановитьПараметрыСКД();
	
КонецПроцедуры  

// #wortmann {
// #2.3.09
// Добавление процедуры для кнопки "Сформировать строки перевода"
// Параметры:
//  Команда - команда - команда кнопки
// XYZ Юрий 2022/09/20
&НаКлиенте
Процедура СформироватьСтрокиПеревода(Команда)
	
	П = Новый Структура;
	П.Вставить("МассивНоменклатур", МассивНоменклатур());
	П.Вставить("ЯзыкПеревода", ПредопределенноеЗначение("Справочник.гф_ВидыЯзыков.Russian"));
	П.Вставить("ТолькоБезПеревода", Истина);
	
	Если МассивНоменклатур() <> Неопределено Тогда
		ОткрытьФорму("Обработка.гф_ДиспетчерПереводов.Форма.ФормаПереводаОбъектов", П, ЭтотОбъект);
	Иначе
		ОбщегоНазначенияКлиент.СообщитьПользователю("Нет выбранных документов!");
	КонецЕсли;
		
КонецПроцедуры // } #wortmann

// #wortmann {
// #2.3.09
// Для кнопки "Сформировать строки перевода"
// Возвращаемое значение:
//  Массив - массив номенклатур
// XYZ Юрий 2022/09/20
&НаСервере
Функция МассивНоменклатур()
	
	мТовары = Новый Массив;
	
	ПомеченныеДокументы = Отчет.ТаблицаДокументы.Выгрузить(Новый Структура("Пометка", Истина));
	
	Если ПомеченныеДокументы.Количество() = 0 Тогда	
		Возврат Неопределено;
	КонецЕсли;
	
	Для каждого Док Из ПомеченныеДокументы.ВыгрузитьКолонку("Документ")  Цикл
	
		Для каждого Товар Из Док.Товары Цикл
			
		    Если ИскатьПереводы(Товар.Номенклатура) Тогда
				мТовары.Добавить(Товар.Номенклатура);	
			КонецЕсли;
			
		КонецЦикла;	
	
	КонецЦикла;
	
	Возврат мТовары;

КонецФункции // } #wortmann

// #wortmann {
// #2.3.09
// Для кнопки "Сформировать строки перевода"
// Параметры:
//  Номенклатура - СправочникСсылка.Номенклатура - элемент справочника "Номенклатура"
// Возвращаемое значение:
//  ВыборкаИзРезультатаЗапроса - выбора из регистра "Дополнительные сведения" (Объект, Свойство, Значение)
// XYZ Юрий 2022/09/20
&НаСервере
Функция ИскатьПереводы(Номенклатура)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	а.Объект КАК Объект,
	|	а.Свойство КАК Свойство,
	|	а.Значение КАК Значение
	|ИЗ
	|	РегистрСведений.ДополнительныеСведения КАК а
	|ГДЕ
	|	а.Объект = &Объект
	|	И а.Свойство = &Свойство");
	Запрос.УстановитьПараметр("Объект", Номенклатура);
	
	стрЗначение = "гф_НоменклатураДатаОбновленияНоменклатурыИзI5";
	значениеСвойство = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("имя", стрЗначение);
	Запрос.УстановитьПараметр("Свойство", значениеСвойство);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Возврат Выборка.Следующий();
	
КонецФункции // } #wortmann 




