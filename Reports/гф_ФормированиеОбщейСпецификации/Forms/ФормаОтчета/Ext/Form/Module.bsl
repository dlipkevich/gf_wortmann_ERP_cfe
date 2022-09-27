﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка) 
	//ЗаполнитьСписокВыбораВидаОтчета();
	Отчет.Вид = "РеализацииПокупателей";
	УстановитьВидимостьРеквизитов(); 
	УстановитьВариантОтчета()
	//ЗаполнитьНастройкиОтбора();
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
	
	
	
	//Если Отчет.ФормироватьВПарах Тогда
	//	  УстановитьТекущийВариант("ВПарах");
	//Иначе
	//	 УстановитьТекущийВариант("ВКоробах");
	//КонецЕсли;
	 
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
	
	ИмяСКД = "Схема"+Отчет.Вид+?(Отчет.ФормироватьВПарах,"ВПарах","ВКоробах");
	
	СхемаКомпоновкиДанных = ОтчетОбъект.ПолучитьМакет(ИмяСКД);
	
	Отчет.АдресСхемы = ПоместитьВоВременноеХранилище(СхемаКомпоновкиДанных, УникальныйИдентификатор);
	
	Отчет.КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(Отчет.АдресСхемы));
    Отчет.КомпоновщикНастроек.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию); 
	//Отчет.КомпоновщикНастроек.ЗагрузитьНастройки(НстройкиСКД);
	Отчет.КомпоновщикНастроек.Восстановить();
		
КонецПроцедуры	

&НаСервере
Процедура УстановитьВидимостьРеквизитов()  
	
	Элементы.КонецПериода.АвтоОтметкаНезаполненного = Ложь;
	Элементы.СкладПолучатель.АвтоОтметкаНезаполненного = Ложь;
	Элементы.ЦенаСоСкидкой.АвтоОтметкаНезаполненного = Ложь;
	Элементы.ДатаОстатков.АвтоОтметкаНезаполненного = Ложь;
		
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
	ИначеЕсли Отчет.Вид = "ПриобретениеТоваровИУслуг" Тогда
		Элементы.ФормироватьВПарах.Видимость = Истина;
		Элементы.НачалоПериода.Видимость = Ложь;
		Элементы.КонецПериода.Видимость = Ложь;
		Элементы.Контрагент.Видимость = Истина;
		Элементы.ДоговорКонтрагента.Видимость = Истина;
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Ложь;
		Элементы.ДатаОстатков.Видимость = Истина; 
		Элементы.ЦенаСоСкидкой.Видимость = Ложь;
		Элементы.КомпоновщикОтбораНоменклатурыНастройкиОтбор.Видимость = Ложь;
		Элементы.ТаблицаДокументы.Видимость = Истина;
		
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыПометка.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДокумент.Видимость = Истина;	
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыКонтрагент.Видимость = Истина;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыДоговорКонтрагента.Видимость = Истина;		
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладОтправитель.Видимость = Ложь;
		Элементы.ТаблицаДокументы.ПодчиненныеЭлементы.ТаблицаДокументыСкладПолучатель.Видимость = Ложь;
		
	ИначеЕсли Отчет.Вид = "ВнутренниеЗаказы" Тогда
		
		Элементы.ФормироватьВПарах.Видимость = Ложь;
		
		Отчет.ФормироватьВПарах = Истина;
		
		Элементы.НачалоПериода.Видимость = Истина;
		Элементы.КонецПериода.Видимость = Истина;
		Элементы.Контрагент.Видимость = Истина;
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
		Элементы.КонецПериода.Видимость = Ложь;
		Элементы.Контрагент.Видимость = Ложь;
		Элементы.ДоговорКонтрагента.Видимость = Ложь;
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Истина;
		Элементы.СкладПолучатель.Заголовок = "Склад";
		Элементы.ДатаОстатков.Видимость = Истина;
		Элементы.ЦенаСоСкидкой.Видимость = Истина;
		
		Элементы.ДатаОстатков.АвтоОтметкаНезаполненного = Истина;
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
		Элементы.КонецПериода.Видимость = Ложь;
		Элементы.КонецПериода.АвтоОтметкаНезаполненного = Истина;
		Элементы.Контрагент.Видимость = Ложь;
		Элементы.ДоговорКонтрагента.Видимость = Ложь;
		Элементы.СкладОтправитель.Видимость = Ложь;
		Элементы.СкладПолучатель.Видимость = Истина;
		Элементы.СкладПолучатель.Заголовок = "Склад";
		Элементы.СкладПолучатель.АвтоОтметкаНезаполненного = Истина;
		Элементы.ДатаОстатков.Видимость = Истина;
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
		Элементы.КомпоновщикОтбораНоменклатурыНастройкиОтбор.Видимость = Истина;
		
		Элементы.ДатаОстатков.Видимость = Ложь;
		Элементы.ЦенаСоСкидкой.Видимость = Ложь;		
		Элементы.ТаблицаДокументы.Видимость = Ложь;
		
		УстановитьТекущийВариант(?(Отчет.ФормироватьВПарах,"ВПарах","ВКоробах"));
		
		ЗаполнитьНастройкиОтбора();
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
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДокументы_РеализацииПокупателей()
	
	Запрос = новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
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
	
	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(Отчет.НачалоПериода));
	Запрос.УстановитьПараметр("КонецПериода",НачалоДня(Отчет.КонецПериода));
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
	"ВЫБРАТЬ
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
	
	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(Отчет.НачалоПериода));
	Запрос.УстановитьПараметр("КонецПериода",НачалоДня(Отчет.КонецПериода));
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
	"ВЫБРАТЬ
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
	
	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(Отчет.НачалоПериода));
	Запрос.УстановитьПараметр("КонецПериода",НачалоДня(Отчет.КонецПериода));
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
	"ВЫБРАТЬ
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
	Запрос.УстановитьПараметр("КонецПериода", НачалоДня(Отчет.КонецПериода));
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
	"ВЫБРАТЬ
	|	ВнутреннееПотреблениеТоваров.Ссылка КАК Документ,
	|	ВнутреннееПотреблениеТоваров.гф_Контрагент КАК Контрагент
	|ИЗ
	|	Документ.ВнутреннееПотреблениеТоваров КАК ВнутреннееПотреблениеТоваров
	|ГДЕ
	|	ВнутреннееПотреблениеТоваров.Дата МЕЖДУ &НачалоПериода И &КонецПериода
	|	И ВнутреннееПотреблениеТоваров.Проведен = ИСТИНА
	|	И ВЫБОР
	|			КОГДА &ОтборПоКонтрагенту
	|				ТОГДА ВнутреннееПотреблениеТоваров.гф_Контрагент = &Контрагент
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|	И ВнутреннееПотреблениеТоваров.Организация = &Организация";
	
	Запрос.УстановитьПараметр("НачалоПериода",НачалоДня(Отчет.НачалоПериода));
	Запрос.УстановитьПараметр("КонецПериода",НачалоДня(Отчет.КонецПериода));
	Запрос.УстановитьПараметр("ОтборПоКонтрагенту",ЗначениеЗаполнено(Отчет.Контрагент));
	Запрос.УстановитьПараметр("Контрагент",Отчет.Контрагент);
	Запрос.УстановитьПараметр("ДоговорКонтрагента",Отчет.ДоговорКонтрагента);
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
Процедура ФормироватьВПарахПриИзменении(Элемент)
	
	УстановитьПараметрыСКД();
	
КонецПроцедуры

