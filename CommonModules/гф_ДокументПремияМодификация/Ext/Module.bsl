﻿
Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	ВывестиВКоллекциюПечатнуюФорму("Отчет.ПечатнаяФормаТ11",
		МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода);
		
КонецПроцедуры
	
// Выводит в коллекцию печатных форм табличный документ настраиваемой печатной формы.
// Используется при формировании настраиваемых печатных форм из модулей менеджеров отчетов - печатных форм.
//
// Параметры:
//   ИмяОтчета                           - Строка, полное имя объекта метаданных - отчета
//   МассивОбъектов                      - см. УправлениеПечатьюПереопределяемый.ПриПечати.ОбъектыПечати
//   ПараметрыПечати                     - см. УправлениеПечатьюПереопределяемый.ПриПечати.ОбъектыПечати
//   КоллекцияПечатныхФорм               - см. УправлениеПечатьюПереопределяемый.ПриПечати.ОбъектыПечати
//   ОбъектыПечати                       - см. УправлениеПечатьюПереопределяемый.ПриПечати.ОбъектыПечати
//   ПараметрыВывода                     - см. УправлениеПечатьюПереопределяемый.ПриПечати.ОбъектыПечати
//   ВнешниеНаборыДанных                 - Структура
//   ДополнительныеПараметрыФормирования - Структура
//
Процедура ВывестиВКоллекциюПечатнуюФорму(ИмяОтчета, МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода, ВнешниеНаборыДанных = Неопределено, ДополнительныеПараметрыФормирования = Неопределено) Экспорт
	
	ВариантыОтчетовПечатныхФорм = МакетыВариантовОтчетовПечатныхФорм();
	Для Каждого ОписаниеНастраиваемойФормы Из ВариантыОтчетовПечатныхФорм Цикл
		
		ПутьКВариантуОтчета = ОписаниеНастраиваемойФормы.Ключ;
		Если СтрНайти(ПутьКВариантуОтчета, ИмяОтчета) = 1 Тогда
			
			ПутьКМакетуПечатнойФормы = ОписаниеНастраиваемойФормы.Значение;
			ИмяМакетаПечатнойФормы = ЗарплатаКадрыОтчеты.ИмяМакетаИзПутиКМакетуПечатнойФормы(ПутьКМакетуПечатнойФормы);
			
			Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, ИмяМакетаПечатнойФормы) Тогда
				
				Если ДополнительныеПараметрыФормирования = Неопределено Тогда
					ДополнительныеПараметры = Новый Структура;
				Иначе
					ДополнительныеПараметры = ОбщегоНазначения.СкопироватьРекурсивно(ДополнительныеПараметрыФормирования);
				КонецЕсли;
				
				ДокументРезультат = Новый ТабличныйДокумент;
				
				КлючВарианта = ЗарплатаКадрыОтчеты.КлючВариантаИзПутиКВарианту(ПутьКВариантуОтчета);
				
				Если ВРег(Лев(ПутьКМакетуПечатнойФормы, 11)) = ВРег("ОбщийМакет.") Тогда
					ПредставлениеПечатнойФормы = Метаданные.ОбщиеМакеты[ИмяМакетаПечатнойФормы].Синоним;
				Иначе
					ПредставлениеПечатнойФормы = Метаданные.НайтиПоПолномуИмени(ИмяОтчета).Макеты[ИмяМакетаПечатнойФормы].Синоним;
				КонецЕсли;
				
				ОбъектОтчета = ОбщегоНазначения.ОбъектПоПолномуИмени(ИмяОтчета);
				
				Если ДополнительныеПараметры.Свойство("Отбор") Тогда
					МакетКомпоновкиДанных = Неопределено;
				Иначе
					МакетКомпоновкиДанных = ЗарплатаКадрыОтчеты.МакетКомпоновкиДанныхОтчета(ОбъектОтчета, КлючВарианта);
				КонецЕсли;
				
				Если МакетКомпоновкиДанных = Неопределено Тогда
					
					НастройкиОтчетаКД = Неопределено;
					ПользовательскиеНастройкиКД = Неопределено;
					
					ЗарплатаКадрыОтчеты.ИнициализироватьНастройкиОтчета(ОбъектОтчета, "", КлючВарианта, НастройкиОтчетаКД,
						ПользовательскиеНастройкиКД);
					
					Если НастройкиОтчетаКД = Неопределено Тогда
						НастройкиОтчетаКД = ОбъектОтчета.СхемаКомпоновкиДанных.ВариантыНастроек[КлючВарианта].Настройки;
					КонецЕсли;
					
					ОбъектОтчета.КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиОтчетаКД);
					Если ТипЗнч(ПользовательскиеНастройкиКД) = Тип("ПользовательскиеНастройкиКомпоновкиДанных") Тогда
						ОбъектОтчета.КомпоновщикНастроек.ЗагрузитьПользовательскиеНастройки(ПользовательскиеНастройкиКД);
					КонецЕсли;
					
					ЗарплатаКадрыОтчеты.УстановитьПараметрОтбора(ОбъектОтчета, МассивОбъектов);
					
				Иначе
					
					ОбъектОтчета.КомпоновщикНастроек.ПользовательскиеНастройки.ДополнительныеСвойства.Вставить(
						"МакетКомпоновкиДанных", МакетКомпоновкиДанных);
					
					ПараметрКлючВарианта = МакетКомпоновкиДанных.ЗначенияПараметров.Найти("КлючВарианта");
					Если ПараметрКлючВарианта <> Неопределено Тогда
						ДополнительныеПараметры.Вставить("КлючВарианта", ПараметрКлючВарианта.Значение);
					КонецЕсли;
					
					Для каждого Параметр Из МакетКомпоновкиДанных.ЗначенияПараметров Цикл
						
						ПараметрКомпоновщика = Лев(Параметр.Имя, 1) = "П"
							И СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(Сред(Параметр.Имя, 2));
						
						Если Параметр.Имя = "СсылкиНаОбъекты"
							Или ПараметрКомпоновщика
								И ТипЗнч(Параметр.Значение) = Тип("СписокЗначений")
								И Не ЗначениеЗаполнено(Параметр.Значение) Тогда
							
							Параметр.Значение.ЗагрузитьЗначения(МассивОбъектов);
							
						КонецЕсли;
						
					КонецЦикла;
					
				КонецЕсли;
				
				РезультатКомпоновки = РезультатКомпоновкиМакетаПечатнойФормы(ОбъектОтчета, , , ВнешниеНаборыДанных, ДополнительныеПараметры);
				
				Сформировать(ДокументРезультат, РезультатКомпоновки, ОбъектыПечати, ПараметрыПечати);
				
				УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
					КоллекцияПечатныхФорм,
					ИмяМакетаПечатнойФормы,
					ПредставлениеПечатнойФормы,
					ДокументРезультат,,);
				
				Прервать;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура Сформировать(ДокументРезультат, РезультатКомпоновки, ОбъектыПечати = Неопределено, ПараметрыПечати = Неопределено) Экспорт
	
	Если РезультатКомпоновки.ОтчетПустой Тогда
		Возврат;
	КонецЕсли;
	
	Если РезультатКомпоновки.КлючВарианта = "Т11" Тогда
		ВывестиНаПечатьТ11(ДокументРезультат, РезультатКомпоновки, ОбъектыПечати);
	ИначеЕсли РезультатКомпоновки.КлючВарианта = "Т11а" Тогда
		ВывестиНаПечатьТ11а(ДокументРезультат, РезультатКомпоновки, ОбъектыПечати);
	КонецЕсли;
	
КонецПроцедуры

Процедура ВывестиНаПечатьТ11(ДокументРезультат, РезультатКомпоновки, ОбъектыПечати)
	
	ДокументРезультат.КлючПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_Премия_Т11";
	ДокументРезультат.ОриентацияСтраницы= ОриентацияСтраницы.Портрет;
	ДокументРезультат.АвтоМасштаб = Истина;
	
	Для Каждого ДанныеНаПечать Из РезультатКомпоновки.ДанныеОтчета.Строки Цикл
		
		Если ДокументРезультат.ВысотаТаблицы > 0 Тогда
			ДокументРезультат.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		ПерваяСтрокаПечатнойФормы = ДокументРезультат.ВысотаТаблицы + 1;
		
		ВывестиГоризонтальныйРазделитель = Ложь;
		Для Каждого ДанныеДетальныхЗаписей Из ДанныеНаПечать.Строки Цикл
			
			Если ВывестиГоризонтальныйРазделитель Тогда
				ДокументРезультат.ВывестиГоризонтальныйРазделительСтраниц();
			Иначе
				ВывестиГоризонтальныйРазделитель = Истина;
			КонецЕсли;
			
			Если ДанныеНаПечать.Строки.Количество() = 1 Тогда
				НомерНаПечать = Строка(ДанныеДетальныхЗаписей.СсылкаНаОбъектНомерНаПечать);
			Иначе
				НомерНаПечать = Строка(ДанныеДетальныхЗаписей.СсылкаНаОбъектНомерНаПечать) + "/"
					+ ДанныеДетальныхЗаписей.ДанныеПоощренияНомерСтроки;
			КонецЕсли;
			ДанныеПользовательскихПолей = ЗарплатаКадрыОтчеты.ЗначенияЗаполненияПользовательскихПолей(РезультатКомпоновки.ИдентификаторыМакета,
											ДанныеДетальныхЗаписей);
			ДанныеПользовательскихПолей.Вставить("СсылкаНаОбъектНомерНаПечать", НомерНаПечать);
			
			ПолучитьДополнительныеСведения(ДанныеДетальныхЗаписей);
			
			ЗарплатаКадрыОтчеты.ВывестиВДокументРезультатОбластиМакета(
				ДокументРезультат,
				РезультатКомпоновки.МакетПечатнойФормы,
				"Приказ",
				ДанныеНаПечать,
				ДанныеДетальныхЗаписей,
				ДанныеПользовательскихПолей);
			
		КонецЦикла;
		
		Если ОбъектыПечати <> Неопределено Тогда
			УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ДокументРезультат, ПерваяСтрокаПечатнойФормы, ОбъектыПечати,
				ДанныеНаПечать.СсылкаНаОбъект);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ВывестиНаПечатьТ11а(ДокументРезультат, РезультатКомпоновки, ОбъектыПечати)
	
	ДокументРезультат.КлючПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_Премия_Т11а";
	ДокументРезультат.ОриентацияСтраницы= ОриентацияСтраницы.Портрет;
	ДокументРезультат.АвтоМасштаб = Истина;
	
	Для Каждого ДанныеНаПечать Из РезультатКомпоновки.ДанныеОтчета.Строки Цикл
		
		Если ДокументРезультат.ВысотаТаблицы > 0 Тогда
			ДокументРезультат.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		ПерваяСтрокаПечатнойФормы = ДокументРезультат.ВысотаТаблицы + 1;
		
		ДанныеПользовательскихПолейШапки = ЗарплатаКадрыОтчеты.ЗначенияЗаполненияПользовательскихПолей(РезультатКомпоновки.ИдентификаторыМакета,
											ДанныеНаПечать);
		
		ПолучитьДополнительныеСведения(ДанныеНаПечать);
		
		ЗарплатаКадрыОтчеты.ВывестиВДокументРезультатОбластиМакета(
			ДокументРезультат, РезультатКомпоновки.МакетПечатнойФормы, "Шапка",
			ДанныеНаПечать,
			ДанныеПользовательскихПолейШапки);
		
		ОбластьШапкиТаблицы = РезультатКомпоновки.МакетПечатнойФормы.ПолучитьОбласть("ШапкаПовторятьПриПечати");
		ЗарплатаКадрыОтчеты.ЗаполнитьПараметрыОбластиМакета(ОбластьШапкиТаблицы,
			ДанныеНаПечать,
			ДанныеПользовательскихПолейШапки);
		
		ОбластьПодвал = РезультатКомпоновки.МакетПечатнойФормы.ПолучитьОбласть("Подвал");
		ЗарплатаКадрыОтчеты.ЗаполнитьПараметрыОбластиМакета(ОбластьПодвал,
			ДанныеНаПечать,
			ДанныеПользовательскихПолейШапки);
		
		Для Каждого ДанныеДетальныхЗаписей Из ДанныеНаПечать.Строки Цикл
			
			ДанныеПользовательскихПолей = ЗарплатаКадрыОтчеты.ЗначенияЗаполненияПользовательскихПолей(РезультатКомпоновки.ИдентификаторыМакета,
											ДанныеДетальныхЗаписей);
			
			ОбластьСтроки = РезультатКомпоновки.МакетПечатнойФормы.ПолучитьОбласть("Строка");
			ЗарплатаКадрыОтчеты.ЗаполнитьПараметрыОбластиМакета(ОбластьСтроки,
				ДанныеНаПечать,
				ДанныеДетальныхЗаписей,
				ДанныеПользовательскихПолей);
			
			СписокУмещаемыхОбластей = Новый Массив;
			СписокУмещаемыхОбластей.Добавить(ОбластьСтроки);
			СписокУмещаемыхОбластей.Добавить(ОбластьПодвал);
			
			Если НЕ ДокументРезультат.ПроверитьВывод(СписокУмещаемыхОбластей) Тогда
				
				ДокументРезультат.ВывестиГоризонтальныйРазделительСтраниц();
				ДокументРезультат.Вывести(ОбластьШапкиТаблицы);
				
			КонецЕсли;
			
			ДокументРезультат.Вывести(ОбластьСтроки);
			
		КонецЦикла;
		
		ДокументРезультат.Вывести(ОбластьПодвал);
		
		Если ОбъектыПечати <> Неопределено Тогда
			УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ДокументРезультат, ПерваяСтрокаПечатнойФормы, ОбъектыПечати,
				ДанныеНаПечать.СсылкаНаОбъект);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПолучитьДополнительныеСведения(ДанныеНаПечать)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДополнительныеСведения.Значение КАК Значение,
	|	ДополнительныеРеквизитыИСведения.Имя КАК Имя,
	|	ЗначенияСвойствОбъектов.ПолноеНаименование КАК ПолноеНаименование
	|ИЗ
	|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДополнительныеРеквизитыИСведения
	|		ПО (ДополнительныеСведения.Свойство = ДополнительныеРеквизитыИСведения.Ссылка)
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ЗначенияСвойствОбъектов КАК ЗначенияСвойствОбъектов
	|		ПО (ДополнительныеСведения.Значение.Ссылка = ЗначенияСвойствОбъектов.Ссылка)
	|ГДЕ
	|	ДополнительныеСведения.Объект = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", ДанныеНаПечать.СсылкаНаОбъект);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		СтруктураПроверка = Новый Структура;
		СтруктураПроверка.Вставить("СсылкаНаОбъектМотивПоощрения", NULL);
		ЗаполнитьЗначенияСвойств(СтруктураПроверка, ДанныеНаПечать);
		
		Если Не СтруктураПроверка["СсылкаНаОбъектМотивПоощрения"] = NULL
			И ВыборкаДетальныеЗаписи.Имя = "гф_МотивПоощрения" Тогда
			
			ДанныеНаПечать.СсылкаНаОбъектМотивПоощрения = ВыборкаДетальныеЗаписи.ПолноеНаименование;
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
			
КонецПроцедуры

Функция РезультатКомпоновкиМакетаПечатнойФормы(ОбъектОтчета, ДанныеРасшифровки = Неопределено, 
	НастройкиОтчета = Неопределено, ВнешниеНаборыДанных = Неопределено, ДополнительныеПараметры = Неопределено) // Экспорт
	
	РезультатКомпоновкиМакета = Новый Структура;
	КомпоновщикНастроек2 = ОбъектОтчета.КомпоновщикНастроек;
	
	// Заполняется коллекция идентификаторов пользовательских полей
	Если НастройкиОтчета = Неопределено Тогда
		НастройкиОтчета = КомпоновщикНастроек2.ПолучитьНастройки();
	КонецЕсли;
	
	РезультатКомпоновкиМакета.Вставить("КлючВарианта", ЗарплатаКадрыОтчеты.КлючВарианта(НастройкиОтчета));
	ДопСвойства = КомпоновщикНастроек2.ПользовательскиеНастройки.ДополнительныеСвойства;
	
	Если ДополнительныеПараметры <> Неопределено Тогда
		
		Если ДополнительныеПараметры.Свойство("Отбор") Тогда
			
			Для Каждого ОписаниеОтбора Из ДополнительныеПараметры.Отбор Цикл
				
				ЭлементОтбора = НастройкиОтчета.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
				
				ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ОписаниеОтбора.ЛевоеЗначение);
				ЭлементОтбора.ПравоеЗначение = ОписаниеОтбора.ПравоеЗначение;
				ЭлементОтбора.ВидСравнения = ОписаниеОтбора.ВидСравнения;
				
			КонецЦикла;
			
		КонецЕсли;
		
		Если ДополнительныеПараметры.Свойство("КлючВарианта") Тогда
			РезультатКомпоновкиМакета.Вставить("КлючВарианта", ДополнительныеПараметры.КлючВарианта);
		КонецЕсли;
		
	КонецЕсли;
	
	Если ДопСвойства.Свойство("ИспользуютсяПользовательскиеНастройкиПечати") Тогда
		НастроитьВыводПользовательскихПолейОтчета(НастройкиОтчета);
	КонецЕсли;
	
	ИдентификаторыМакета = ЗарплатаКадрыОтчеты.СоответствиеПользовательскихПолей(НастройкиОтчета);
	РезультатКомпоновкиМакета.Вставить("ИдентификаторыМакета", ИдентификаторыМакета);
	
	// Определяется макет печатной формы
	МакетПечатнойФормы = Неопределено;
	ДопСвойства.Свойство("МакетПечатнойФормы", МакетПечатнойФормы);
	
	Если МакетПечатнойФормы = Неопределено Тогда
		
		МакетыВариантовОтчетов = МакетыВариантовОтчетовПечатныхФорм();
		ПолноеИмяОбъекта = ОбъектОтчета.Метаданные().ПолноеИмя();
		МенеджерПечати = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ПолноеИмяОбъекта);
		МакетПечатнойФормы = МенеджерПечати.ПолучитьМакет("ПФ_MXL_" + РезультатКомпоновкиМакета.КлючВарианта);
		
	КонецЕсли;
	
	РезультатКомпоновкиМакета.Вставить("МакетПечатнойФормы", МакетПечатнойФормы);
	
	Если ДопСвойства.Свойство("МакетКомпоновкиДанных")
		И ДопСвойства.МакетКомпоновкиДанных <> Неопределено Тогда
		
		МакетКомпоновки = ДопСвойства.МакетКомпоновкиДанных;
		ДопСвойства.Удалить("МакетКомпоновкиДанных");
		
	Иначе
		
		МакетКомпоновки = МакетКомпоновкиДанныхДляКоллекцииЗначений(ОбъектОтчета.СхемаКомпоновкиДанных, НастройкиОтчета,
							ДанныеРасшифровки);
		
	КонецЕсли;
	
	Если ДопСвойства.Свойство("ФормированиеМакетаКомпоновкиДанных") Тогда
		
		ДопСвойства.Вставить("СкомпонованныйМакетКомпоновкиДанных", МакетКомпоновки);
		РезультатКомпоновкиМакета.Вставить("ДанныеОтчета", Новый Массив);
		
		ДопСвойства.Вставить("ОтчетПустой", Истина);
		ДопСвойства.Удалить("ФормированиеМакетаКомпоновкиДанных");
		
	Иначе
		
		ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
		ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных, , Истина);
		
		ДанныеОтчета = Новый ДеревоЗначений;
		
		ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
		ПроцессорВывода.УстановитьОбъект(ДанныеОтчета);
		
		ПроцессорВывода.Вывести(ПроцессорКомпоновки, Истина);
		
		ДопСвойства.Вставить("ОтчетПустой", ДанныеОтчета.Строки.Количество() = 0);
		
		РезультатКомпоновкиМакета.Вставить("ДанныеОтчета", ДанныеОтчета);
		
	КонецЕсли;
	
	РезультатКомпоновкиМакета.Вставить("ОтчетПустой", ДопСвойства.ОтчетПустой);
	
	Возврат РезультатКомпоновкиМакета;
	
КонецФункции

Процедура НастроитьВыводПользовательскихПолейОтчета(НастройкиОтчета)
	
	ОбработанныеПоля = Новый Соответствие;
	Для Каждого ЭлементВыбора Из НастройкиОтчета.Выбор.Элементы Цикл
		
		Если Не ЭлементВыбора.Использование Тогда
			Продолжить;
		КонецЕсли;
		
		Если ОбработанныеПоля.Получить(ЭлементВыбора.Поле) = Истина Тогда
			Продолжить;
		КонецЕсли;
		
		ДоступноеПоле = НастройкиОтчета.ДоступныеПоляВыбора.НайтиПоле(ЭлементВыбора.Поле);
		Если ДоступноеПоле = Неопределено Или ДоступноеПоле.Ресурс Тогда
			Продолжить;
		КонецЕсли;
		
		ПутьПоля = Строка(ЭлементВыбора.Поле);
		
		ПользовательскоеПоле = ПользовательскоеПоле(НастройкиОтчета, ПутьПоля);
		Если ПользовательскоеПоле <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ПозицияСкобки = СтрНайти(ПутьПоля, "[");
		Если ПозицияСкобки = 0 Тогда
			СловаПутиПоля = СтрРазделить(ПутьПоля, ".");
		Иначе
			
			ПутьПоляБезСкобки = Лев(ПутьПоля, ПозицияСкобки - 2);
			СловаПутиПоля = СтрРазделить(ПутьПоляБезСкобки, ".");
			
		КонецЕсли;
		
		Если СловаПутиПоля.Количество() > 1 Тогда
			
			СловаПутиПоля.Удалить(СловаПутиПоля.Количество() - 1);
			ПутьРодителя = СтрСоединить(СловаПутиПоля, ".");
			
			Родитель = Новый ПолеКомпоновкиДанных(ПутьРодителя);
			
		Иначе
			Родитель = Неопределено;
		КонецЕсли;
		
		Если Не ВывестиВСтруктуру(НастройкиОтчета.Структура, ЭлементВыбора.Поле, Родитель) Тогда
			
			ПользовательскоеПоле = НастройкиОтчета.ПользовательскиеПоля.Элементы.Добавить(Тип("ПользовательскоеПолеВыражениеКомпоновкиДанных"));
			ПользовательскоеПоле.Заголовок = ПутьПоля;
			
			ПользовательскоеПоле.УстановитьВыражениеДетальныхЗаписей(ПользовательскоеПоле.Заголовок);
			ПользовательскоеПоле.УстановитьВыражениеИтоговыхЗаписей(ПользовательскоеПоле.Заголовок);
			
			ВыбранноеПоле = Новый ПолеКомпоновкиДанных(ПользовательскоеПоле.ПутьКДанным);
			
			НовоеПоле = НастройкиОтчета.Выбор.Элементы.Добавить(Тип("ВыбранноеПолеКомпоновкиДанных"));
			НовоеПоле.Поле = ВыбранноеПоле;
			
		КонецЕсли;
		
		ОбработанныеПоля.Вставить(ЭлементВыбора.Поле, Истина);
		
	КонецЦикла;
	
КонецПроцедуры

Функция МакетыВариантовОтчетовПечатныхФорм() Экспорт
	
	Возврат ЗарплатаКадрыОтчетыВнутренний.МакетыВариантовОтчетовПечатныхФорм();
	
КонецФункции

Функция МакетКомпоновкиДанныхДляКоллекцииЗначений(Схема, Настройки, ДанныеРасшифровки = Неопределено,
	МакетОформления = Неопределено, ПроверятьДоступностьПолей = Истина, ПараметрыФункциональныхОпций = Неопределено) Экспорт
	
	Возврат МакетКомпоновкиДанных(Схема, Настройки, ДанныеРасшифровки, МакетОформления,
		ПроверятьДоступностьПолей, ПараметрыФункциональныхОпций, Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	
КонецФункции

Функция ПользовательскоеПоле(НастройкиОтчета, ПутьКДанным)
	
	Поле = Неопределено;
	
	Для Каждого ЭлементКоллекции Из НастройкиОтчета.ПользовательскиеПоля.Элементы Цикл
		
		Если ПутьКДанным = ЭлементКоллекции.ПутьКДанным Тогда
			
			Поле = ЭлементКоллекции;
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Поле;
	
КонецФункции

Функция ВывестиВСтруктуру(СтруктураНастроек, Поле, Родитель)
	
	ВыведеноВСтруктуру = Ложь;
	
	Для Каждого ЭлементСтруктуры Из СтруктураНастроек Цикл
		
		Если Не ЭлементСтруктуры.Использование Тогда
			Прервать;
		КонецЕсли;
		
		Для Каждого ЭлементВыбора Из ЭлементСтруктуры.Выбор.Элементы Цикл
			
			Если ТипЗнч(ЭлементВыбора) = Тип("АвтоВыбранноеПолеКомпоновкиДанных") Тогда
				Продолжить;
			КонецЕсли;
			
			Если Поле = ЭлементВыбора.Поле Тогда
				ВыведеноВСтруктуру = Истина;
			КонецЕсли;
			
		КонецЦикла;
		
		Если Не ВыведеноВСтруктуру Тогда
			
			РодительВыведенВСтруктуру = Ложь;
			Для Каждого ЭлементГруппировки Из ЭлементСтруктуры.ПоляГруппировки.Элементы Цикл
				
				Если ТипЗнч(ЭлементГруппировки) = Тип("АвтоПолеГруппировкиКомпоновкиДанных") Тогда
					Продолжить;
				КонецЕсли;
				
				Если Поле = ЭлементГруппировки.Поле Тогда
					ВыведеноВСтруктуру = Истина;
					Прервать;
				ИначеЕсли Родитель = ЭлементГруппировки.Поле Тогда
					РодительВыведенВСтруктуру = Истина;
				КонецЕсли;
				
			КонецЦикла;
			
			Если Не ВыведеноВСтруктуру И РодительВыведенВСтруктуру Тогда
				
				НовоеПоле = ЭлементСтруктуры.ПоляГруппировки.Элементы.Добавить(Тип("ПолеГруппировкиКомпоновкиДанных"));
				НовоеПоле.Поле = Поле;
				
			КонецЕсли;
			
		КонецЕсли;
		
		Если ВыведеноВСтруктуру Тогда
			Прервать;
		ИначеЕсли ВывестиВСтруктуру(ЭлементСтруктуры.Структура, Поле, Родитель) Тогда
			
			ВыведеноВСтруктуру = Истина;
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ВыведеноВСтруктуру;
	
КонецФункции

Функция МакетКомпоновкиДанных(Схема, Настройки, ДанныеРасшифровки = Неопределено, МакетОформления = Неопределено,
	ПроверятьДоступностьПолей = Истина, ПараметрыФункциональныхОпций = Неопределено, ТипГенератора = Неопределено) Экспорт
	
	Если ТипГенератора = Неопределено Тогда
		ТипГенератора = Тип("ГенераторМакетаКомпоновкиДанных");
	КонецЕсли;
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновкиДанных = КомпоновщикМакета.Выполнить(Схема, Настройки, ДанныеРасшифровки, МакетОформления,
		ТипГенератора, ПроверятьДоступностьПолей, ПараметрыФункциональныхОпций);
	
	УточнитьОтборыЗапросовНаборовДанныхМакетаКомпоновкиДанных(МакетКомпоновкиДанных.НаборыДанных);
	
	Возврат МакетКомпоновкиДанных;
	
КонецФункции

Процедура УточнитьОтборыЗапросовНаборовДанныхМакетаКомпоновкиДанных(НаборыДанных)
	
	Для Каждого НаборДанных Из НаборыДанных Цикл
		
		Если ТипЗнч(НаборДанных) = Тип("НаборДанныхОбъединениеМакетаКомпоновкиДанных") Тогда
			УточнитьОтборыЗапросовНаборовДанныхМакетаКомпоновкиДанных(НаборДанных.Элементы);
		ИначеЕсли ТипЗнч(НаборДанных) = Тип("НаборДанныхЗапросМакетаКомпоновкиДанных") Тогда
			
			Если СтрНайти(НаборДанных.Запрос, "NULL ")
				Или СтрНайти(НаборДанных.Запрос, "НЕОПРЕДЕЛЕНО ") Тогда
				
				Схема = Новый СхемаЗапроса;
				Схема.УстановитьТекстЗапроса(НаборДанных.Запрос);
				Для Каждого ЗапросПакета Из Схема.ПакетЗапросов Цикл
					
					Если ТипЗнч(ЗапросПакета) = Тип("ЗапросВыбораСхемыЗапроса") Тогда
						
						Для Каждого ОператорПакета Из ЗапросПакета.Операторы Цикл
							
							ИндексыУдаляемыхОтборов = Новый Массив;
							Для Каждого УсловиеОтбора Из ОператорПакета.Отбор Цикл
								
								Если СтрНачинаетсяС(УсловиеОтбора, "NULL ")
									Или СтрНачинаетсяС(УсловиеОтбора, "НЕ NULL ")
									Или СтрНачинаетсяС(УсловиеОтбора, "НЕОПРЕДЕЛЕНО ")
									Или СтрНачинаетсяС(УсловиеОтбора, "НЕ НЕОПРЕДЕЛЕНО ") Тогда
									
									ИндексыУдаляемыхОтборов.Вставить(0, ОператорПакета.Отбор.Индекс(УсловиеОтбора));
									
								КонецЕсли;
								
							КонецЦикла;
							
							Для Каждого ИндексУдаляемогоОтбора Из ИндексыУдаляемыхОтборов Цикл
								ОператорПакета.Отбор.Удалить(ИндексУдаляемогоОтбора);
							КонецЦикла;
							
						КонецЦикла;
						
					КонецЕсли;
					
				КонецЦикла;
				
				НаборДанных.Запрос = Схема.ПолучитьТекстЗапроса();
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры
