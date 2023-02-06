﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

&После("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ)
	
	// #wortmann {
	// Галфинд Sakovich 2022/11/08
	ШтрихкодBase64 = ШтрихкодированиеИСКлиентСервер.ШтрихкодВBase64(ЗначениеШтрихкода);
	Если гф_ЗначениеШтрихкодаBase64 <> ШтрихкодBase64 Тогда
		гф_ЗначениеШтрихкодаBase64 = ШтрихкодBase64;
	КонецЕсли;
	// } #wortmann
	
КонецПроцедуры

&После("ПриЗаписи")
Процедура гф_ПриЗаписи(Отказ)
	
	// #wortmann {
	// Галфинд Sakovich 2022/12/21
	гф_ЗаписатьДанныеАгрегацииВПул();
	// } #wortmann	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&ИзменениеИКонтроль("ЗаполнениеСлужебныхПолейДляGS1")
Процедура гф_ЗаполнениеСлужебныхПолейДляGS1()

	// Только для типов штрихкодов GS1_128 и GS1_DataBarExpandedStacked, для SSCC и Code-128 в ЕГАИС формат штрихкода жестко установлен
	Если ТипШтрихкода = Перечисления.ТипыШтрихкодов.GS1_128
		Или ТипШтрихкода = Перечисления.ТипыШтрихкодов.GS1_DataBarExpandedStacked
		Или ТипШтрихкода = Перечисления.ТипыШтрихкодов.GS1_DataMatrix Тогда

		Если ЭтоНовый() Тогда
			ОбновитьРеквизитыGS1 = (ЗначениеЗаполнено(ЗначениеШтрихкода) И Не ЗначениеЗаполнено(ХешСуммаНормализации));
		Иначе
			ОбновитьРеквизитыGS1 = ЗначениеШтрихкода <> ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "ЗначениеШтрихкода");
		КонецЕсли;

		Если ОбновитьРеквизитыGS1 Тогда

			ПараметрыШтрихкода = ШтрихкодыУпаковокКлиентСервер.ПараметрыШтрихкода(ЗначениеШтрихкода);
			Результат          = ПараметрыШтрихкода.Результат;

			ХешСуммаНормализации = "";

			Если Результат <> Неопределено Тогда

				НомерПартии   = "";
				СерийныйНомер = 0;

				Если ПараметрыШтрихкода.ТипШтрихкода <> Перечисления.ТипыШтрихкодов.SSCC Тогда

					Для Каждого СвойствоШтрихкода Из Результат Цикл
						#Вставка
						// #wortmann {
						// Галфинд Sakovich 2022/10/10
						Если ТипЗнч(Результат) = Тип("Структура") И Результат.Свойство("ИмяИдентификатора") Тогда
						// } #wortmann
						#КонецВставки
						Если СвойствоШтрихкода.ИмяИдентификатора = ВРег("НомерПартии") Тогда
							НомерПартии = СвойствоШтрихкода.Значение;
						ИначеЕсли СвойствоШтрихкода.ИмяИдентификатора = ВРег("СерийныйНомер") Тогда
							СерийныйНомер = СвойствоШтрихкода.Значение;
						КонецЕсли;
						#Вставка
						// #wortmann {
						// Галфинд Sakovich 2022/10/10
						КонецЕсли;
						// } #wortmann
						#КонецВставки
						Если ЗначениеЗаполнено(НомерПартии) И ЗначениеЗаполнено(СерийныйНомер) Тогда
							Прервать;
						КонецЕсли;
					КонецЦикла;

				КонецЕсли;

				Справочники.ШтрихкодыУпаковокТоваров.ЗаполнитьСвойствоХешСуммаЗначенияШтрихкода(ЭтотОбъект, ПараметрыШтрихкода);

			КонецЕсли;

		КонецЕсли;

	Иначе

		Если ЗначениеЗаполнено(ХешСуммаНормализации) И Не ЭтоНовый()
			И ЗначениеШтрихкода <> ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка, "ЗначениеШтрихкода") Тогда
			ХешСуммаНормализации = "";
		КонецЕсли;

		НомерПартии   = "";
		СерийныйНомер = 0;

	КонецЕсли;

КонецПроцедуры

Процедура гф_ЗаписатьДанныеАгрегацииВПул()

	ОбработатьВложенныеШтрихкодыВПуле = Неопределено;
	
	// данное доп.свойство устанавливается в модуле документа "Упаковочный лист"
	// а также в обработке "Рабочее место кладовщика" (при обработке исключений)
	ДополнительныеСвойства.Свойство("ОбработатьВложенныеШтрихкодыВПуле", ОбработатьВложенныеШтрихкодыВПуле);	
	
	Если ОбработатьВложенныеШтрихкодыВПуле = Истина
		И ТипУпаковки = Перечисления.ТипыУпаковок.МультитоварнаяУпаковка
		И ТипШтрихкода = Перечисления.ТипыШтрихкодов.GS1_128 Тогда
		
		мВложенныхШтрихкодов = ВложенныеШтрихкоды.ВыгрузитьКолонку("Штрихкод");	
		КодыМаркировки = ШтрихкодированиеИСМП.НоваяТаблицаПоискаКодаМаркировкиВПуле();
		Для каждого Эл Из мВложенныхШтрихкодов Цикл
			влШтрихКод = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Эл, "ЗначениеШтрихкода");
			ШтрихкодированиеИСМП.ДобавитьКодМаркировкиВТаблицуДляПоискаВПуле(
			влШтрихКод,
			КодыМаркировки);
		КонецЦикла;	
		РезультатПоискаВПуле = ШтрихкодированиеИСМП.РезультатПоискаВПулеКодовМаркировки(
		КодыМаркировки,
		"ДокументОснование, ЗаказНаЭмиссию, ХешСуммаКодаМаркировки, ШтрихкодУпаковки");

		Для каждого СтрокаРезультата Из РезультатПоискаВПуле Цикл
		
			Если СтрокаРезультата["ШтрихкодУпаковки"] <> Ссылка Тогда
			
				Набор = РегистрыСведений.ПулКодовМаркировкиСУЗ.СоздатьНаборЗаписей();
				Отбор = Набор.Отбор;
				Отбор["ДокументОснование"].Установить(СтрокаРезультата["ДокументОснование"]);
				Отбор["ЗаказНаЭмиссию"].Установить(СтрокаРезультата["ЗаказНаЭмиссию"]);
				Отбор["КодМаркировки"].Установить(СтрокаРезультата["КодМаркировки"]);
				Отбор["ХешСуммаКодаМаркировки"].Установить(СтрокаРезультата["ХешСуммаКодаМаркировки"]);
				Набор.Прочитать();
				Для каждого Запись Из Набор Цикл
					Запись["ШтрихкодУпаковки"] = Ссылка;
				КонецЦикла;
				
				Набор.Записать();
				
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#КонецЕсли